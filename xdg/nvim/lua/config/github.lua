local M = {}

function M.copy_permalink()
  local file = vim.api.nvim_buf_get_name(0)
  if file == "" then
    vim.notify("Current buffer has no file", vim.log.levels.WARN)
    return
  end

  local root = vim.fn.systemlist({ "git", "-C", vim.fs.dirname(file), "rev-parse", "--show-toplevel" })[1]
  if vim.v.shell_error ~= 0 then
    vim.notify("Current file is not in a Git repository", vim.log.levels.WARN)
    return
  end

  local path = file:sub(#root + 2)
  local line = vim.api.nvim_win_get_cursor(0)[1]
  local result = vim.system({ "gh", "browse", "--no-browser", "--commit", path .. ":" .. line }, { cwd = root }):wait()
  if result.code ~= 0 then
    vim.notify("Could not create a GitHub permalink: " .. vim.trim(result.stderr), vim.log.levels.WARN)
    return
  end

  vim.fn.setreg("+", vim.trim(result.stdout))
  vim.notify("Copied GitHub permalink")
end

return M
