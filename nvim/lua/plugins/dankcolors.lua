# Disable this as it's practically impossible to see some colours, and default is nice anyway
if true then
  return {}
end

return {
  {
    "RRethy/base16-nvim",
    priority = 1000,
    config = function()
      require("base16-colorscheme").setup({
        base00 = "#11140f",
        base01 = "#11140f",
        base02 = "#6a6c69",
        base03 = "#6a6c69",
        base04 = "#222322",
        base05 = "#bcbfbb",
        base06 = "#bcbfbb",
        base07 = "#bcbfbb",
        base08 = "#9e5f4f",
        base09 = "#9e5f4f",
        base0A = "#4c7b38",
        base0B = "#418c3d",
        base0C = "#6f8764",
        base0D = "#4c7b38",
        base0E = "#a3b89a",
        base0F = "#a3b89a",
      })

      vim.api.nvim_set_hl(0, "Visual", {
        bg = "#6a6c69",
        fg = "#bcbfbb",
        bold = true,
      })
      vim.api.nvim_set_hl(0, "Statusline", {
        bg = "#4c7b38",
        fg = "#11140f",
      })
      vim.api.nvim_set_hl(0, "LineNr", { fg = "#6a6c69" })
      vim.api.nvim_set_hl(0, "CursorLineNr", { fg = "#6f8764", bold = true })

      vim.api.nvim_set_hl(0, "Statement", {
        fg = "#a3b89a",
        bold = true,
      })
      vim.api.nvim_set_hl(0, "Keyword", { link = "Statement" })
      vim.api.nvim_set_hl(0, "Repeat", { link = "Statement" })
      vim.api.nvim_set_hl(0, "Conditional", { link = "Statement" })

      vim.api.nvim_set_hl(0, "Function", {
        fg = "#4c7b38",
        bold = true,
      })
      vim.api.nvim_set_hl(0, "Macro", {
        fg = "#4c7b38",
        italic = true,
      })
      vim.api.nvim_set_hl(0, "@function.macro", { link = "Macro" })

      vim.api.nvim_set_hl(0, "Type", {
        fg = "#6f8764",
        bold = true,
        italic = true,
      })
      vim.api.nvim_set_hl(0, "Structure", { link = "Type" })

      vim.api.nvim_set_hl(0, "String", {
        fg = "#418c3d",
        italic = true,
      })

      vim.api.nvim_set_hl(0, "Operator", { fg = "#222322" })
      vim.api.nvim_set_hl(0, "Delimiter", { fg = "#222322" })
      vim.api.nvim_set_hl(0, "@punctuation.bracket", { link = "Delimiter" })
      vim.api.nvim_set_hl(0, "@punctuation.delimiter", { link = "Delimiter" })

      vim.api.nvim_set_hl(0, "Comment", {
        fg = "#6a6c69",
        italic = true,
      })

      local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
      if not _G._matugen_theme_watcher then
        local uv = vim.uv or vim.loop
        _G._matugen_theme_watcher = uv.new_fs_event()
        _G._matugen_theme_watcher:start(
          current_file_path,
          {},
          vim.schedule_wrap(function()
            local new_spec = dofile(current_file_path)
            if new_spec and new_spec[1] and new_spec[1].config then
              new_spec[1].config()
              print("Theme reload")
            end
          end)
        )
      end
    end,
  },
}
