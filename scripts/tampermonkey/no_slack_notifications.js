// ==UserScript==
// @name         Slack static favicon
// @namespace    http://tampermonkey.net/
// @version      1.0
// @description  Prevent Slack from changing the tab favicon when messages arrive
// @match        https://app.slack.com/*
// @grant        none
// ==/UserScript==

(function () {
    'use strict';

    // choose the favicon you want to keep
    // const STATIC_ICON = "https://a.slack-edge.com/80588/marketing/img/icons/icon_slack_hash_colored.png";
    const STATIC_ICON = "https://slack-imgs.com/?c=1&o1=gu&url=https%3A%2F%2Femoji.slack-edge.com%2FT02AXAJ7YDN%2Fslack-free%2F1bb79b80b70ffd9c.png"

    function setFavicon() {
        let link = document.querySelector("link[rel*='icon']");
        if (!link) {
            link = document.createElement("link");
            link.rel = "icon";
            document.head.appendChild(link);
        }
        link.href = STATIC_ICON;
    }

    // set once
    setFavicon();

    // observe DOM changes (Slack tries to replace it)
    const observer = new MutationObserver(() => {
        const link = document.querySelector("link[rel*='icon']");
        if (link && link.href !== STATIC_ICON) {
            link.href = STATIC_ICON;
            console.log("slack tried changing the icon but I reverted it");
        }
    });

    console.log("Slack favicon script loaded");

    observer.observe(document.head, { childList: true, subtree: true });
})();
