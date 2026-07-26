return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
        },
      },
    },
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = false,
        tofu_ls = {},
      },
    },
  },
  {
    "stevearc/conform.nvim",
    optional = true,
    opts = {
      formatters_by_ft = {
        terraform = { "tofu_fmt" },
        tf = { "tofu_fmt" },
        ["terraform-vars"] = { "tofu_fmt" },
      },
    },
  },
  {
    "mfussenegger/nvim-lint",
    optional = true,
    opts = function(_, opts)
      local terraform_validate = require("lint").linters.terraform_validate
      require("lint").linters.tofu_validate = function()
        local linter = terraform_validate()
        linter.cmd = "tofu"
        return linter
      end

      opts.linters_by_ft = opts.linters_by_ft or {}
      opts.linters_by_ft.terraform = { "tofu_validate" }
      opts.linters_by_ft.tf = { "tofu_validate" }
      opts.linters_by_ft["terraform-vars"] = { "tofu_validate" }
    end,
  },
  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = { "tofu-ls" },
    },
  },
}
