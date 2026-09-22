-- PX4 is a huge submodule; keep background tools from slowing Neovim down.
local px4_autopilot = "/home/benjamin/Work/cdds_ws/applications/PX4-Autopilot/"

local function is_px4_autopilot(path)
  return vim.startswith(path, px4_autopilot)
end

local function root_dir(markers)
  return function(bufnr, on_dir)
    local path = vim.api.nvim_buf_get_name(bufnr)
    if is_px4_autopilot(path) then
      return
    end
    on_dir(vim.fs.root(path, markers))
  end
end

return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    opts = {
      filesystem = {
        filtered_items = {
          hide_dotfiles = false,
          hide_gitignored = true,
          hide_by_name = { "PX4-Autopilot" },
        },
      },
    },
  },
  {
    "ibhagwan/fzf-lua",
    opts = {
      -- Avoid recursively walking the PX4 source tree in file and text pickers.
      files = {
        fd_opts = "--color=never --type f --type l --exclude .git --exclude .jj --exclude PX4-Autopilot",
        rg_opts = [[--color=never --files -g "!.git" -g "!.jj" -g "!applications/PX4-Autopilot/**"]],
      },
      grep = {
        rg_opts = "--column --line-number --no-heading --color=always --smart-case --max-columns=4096 --glob '!applications/PX4-Autopilot/**' -e",
      },
    },
  },
  {
    "nvim-treesitter/nvim-treesitter",
    init = function()
      -- Tree-sitter only parses open buffers, but PX4 files are still expensive.
      vim.api.nvim_create_autocmd("FileType", {
        callback = function(event)
          if is_px4_autopilot(vim.api.nvim_buf_get_name(event.buf)) then
            vim.schedule(function()
              vim.treesitter.stop(event.buf)
            end)
          end
        end,
      })
    end,
  },
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        terraformls = false,
        tofu_ls = { root_dir = root_dir({ ".terraform", ".git" }) },
        ruff = { root_dir = root_dir({ "pyproject.toml", "ruff.toml", ".ruff.toml", ".git" }) },
        ty = { root_dir = root_dir({ "ty.toml", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", ".git" }) },
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
