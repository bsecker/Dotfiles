#!/usr/bin/env python3

import argparse
import json
import os
import pathlib
import select
import subprocess
import time

from evdev import InputDevice, ecodes


CONFIG_PATH = pathlib.Path(__file__).with_name("settings.json")
RUNTIME_DIR = pathlib.Path(os.environ.get("XDG_RUNTIME_DIR", "/tmp"))
STATE_PATH = RUNTIME_DIR / "pomodoro.json"


def read_config():
    with CONFIG_PATH.open() as config_file:
        return json.load(config_file)


def write_state(state):
    temporary_path = STATE_PATH.with_suffix(".tmp")
    with temporary_path.open("w") as state_file:
        json.dump(state, state_file)
    temporary_path.replace(STATE_PATH)


def read_state():
    try:
        with STATE_PATH.open() as state_file:
            return json.load(state_file)
    except (FileNotFoundError, json.JSONDecodeError):
        return None


def duration_for(state, config):
    if state["mode"] == "work":
        return config["work_minutes"] * 60
    if state["long_break"]:
        return config["long_break_minutes"] * 60
    return config["break_seconds"]


def new_state(config):
    now = time.time()
    return {
        "mode": "work",
        "long_break": False,
        "completed_breaks": 0,
        "paused": False,
        "ends_at": now + config["work_minutes"] * 60,
        "paused_remaining": None,
        "expired_at": None,
    }


def notify(state, config):
    if state["mode"] == "break" and state["long_break"]:
        title = "Pomodoro: long break"
        body = "Stretch your legs and change your desk height."
    elif state["mode"] == "break":
        title = "Pomodoro: take a break"
        body = f"Take a {config['break_seconds']}-second break and rest your eyes."
    else:
        title = "Pomodoro: back to work"
        body = "Your break is over. Start the next focus period."
    subprocess.run(["notify-send", title, body], check=False)


def advance(state, config):
    now = time.time()
    if state["mode"] == "work":
        state["mode"] = "break"
        state["completed_breaks"] += 1
        state["long_break"] = state["completed_breaks"] % config["breaks_before_long_break"] == 0
    else:
        state["mode"] = "work"
        state["long_break"] = False
    state["ends_at"] = now + duration_for(state, config)
    state["expired_at"] = None


def control(action, config):
    state = read_state() or new_state(config)
    now = time.time()
    if action == "toggle":
        if state["paused"]:
            state["paused"] = False
            state["ends_at"] = now + state["paused_remaining"]
            state["paused_remaining"] = None
        else:
            state["paused"] = True
            state["paused_remaining"] = max(0, state["ends_at"] - now)
    elif action == "skip":
        advance(state, config)
    write_state(state)


def keyboard_devices(config):
    devices = []
    for path in pathlib.Path("/dev/input").glob("event*"):
        try:
            device = InputDevice(path)
        except OSError:
            continue
        keys = device.capabilities().get(ecodes.EV_KEY, [])
        if config["keyboard_name"] in device.name and ecodes.KEY_A in keys:
            devices.append(device)
    return devices


def run_daemon(config):
    state = new_state(config)
    last_typing_at = 0
    write_state(state)
    devices = keyboard_devices(config)
    poller = select.poll()
    for device in devices:
        poller.register(device.fd, select.POLLIN)

    while True:
        state = read_state() or state
        now = time.time()
        if not state["paused"]:
            if state["expired_at"] is None and now >= state["ends_at"]:
                state["expired_at"] = now
            if state["expired_at"] is not None and now - last_typing_at >= config["typing_quiet_seconds"]:
                advance(state, config)
                write_state(state)
                notify(state, config)

        for fd, _ in poller.poll(500):
            device = next(device for device in devices if device.fd == fd)
            for event in device.read():
                if event.type == ecodes.EV_KEY and event.value == 1:
                    last_typing_at = time.time()


def waybar(config):
    state = read_state()
    if state is None:
        print(json.dumps({"text": "Pomo starting", "class": "unavailable", "tooltip": "Pomodoro timer is starting."}))
        return

    if state["paused"]:
        remaining = state["paused_remaining"]
    else:
        remaining = max(0, state["ends_at"] - time.time())
    minutes, seconds = divmod(int(remaining), 60)
    label = "Break" if state["mode"] == "break" else "Focus"
    if state["long_break"]:
        label = "Long break"
    suffix = " paused" if state["paused"] else ""
    class_name = "paused" if state["paused"] else state["mode"].replace("_", "-")
    if state["expired_at"] is not None:
        class_name = "waiting"
    print(json.dumps({
        "text": f"{label} {minutes:02d}:{seconds:02d}",
        "class": class_name,
        "tooltip": f"{label}{suffix}\nLeft click: pause/resume\nRight click: skip",
    }))


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("command", choices=["daemon", "waybar", "toggle", "skip"])
    args = parser.parse_args()
    config = read_config()
    if args.command == "daemon":
        run_daemon(config)
    elif args.command == "waybar":
        waybar(config)
    else:
        control(args.command, config)


if __name__ == "__main__":
    main()
