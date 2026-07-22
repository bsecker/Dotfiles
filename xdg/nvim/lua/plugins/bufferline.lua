return {
  {
    "akinsho/bufferline.nvim",
    opts = {
      options = {
        -- Keep displaying buffers, not native Neovim tab pages.
        mode = "buffers",

        -- Keep the tab bar visible with only one file.
        always_show_bufferline = true,

        -- More conventional editor-tab behavior.
        diagnostics = "nvim_lsp",
        show_buffer_close_icons = true,
        show_close_icon = true,
        separator_style = "thin",

        -- Preserve tab order rather than rearranging by activity.
        sort_by = "insert_after_current",
      },
    },
  },
}
