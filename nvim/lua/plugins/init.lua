return {
  {
    "folke/which-key.nvim",
    config = function()
      require "configs.which-key"
    end,
  },
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
    end,
  },
  {
    "nvim-tree/nvim-tree.lua",
    cmd = { "NvimTreeToggle", "NvimTreeFocus" },
    opts = function()
      return require "nvchad.configs.nvimtree"
    end,
  },
  {
    "neovim/nvim-lspconfig",
    config = function()
      require("nvchad.configs.lspconfig").defaults()
      require "configs.lspconfig"
    end,
  },

  {
    "mason-org/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "bash-language-server",
        "buf",
        "clang-format",
        "cmake-language-server",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "gradle-language-server",
        "hclfmt",
        "json-lsp",
        "ktlint",
        "marksman",
        "pyright",
        "r-languageserver",
        "ruff",
        "rust-analyzer",
        "shellcheck",
        "shfmt",
        "taplo",
        "terraform-ls",
        "tflint",
        "yaml-language-server",
        -- enabled in configs/lspconfig.lua
        "typescript-language-server",
        "eslint-lsp",
        "tailwindcss-language-server",
        "ty",
        "just-lsp",
        "sqruff",
        "gh-actions-language-server",
        "vscode-home-assistant", -- provides the `home_assistant` LSP binary
      },
    },
  },

  {
    "nvim-treesitter/nvim-treesitter",
    opts = {
      ensure_installed = {
        "vim",
        "lua",
        "vimdoc",
        "html",
        "css",
        "scss",
        "javascript",
        "typescript",
        "tsx",
        "python",
        "rust",
        "csv",
        "json",
        "yaml",
        "tsv",
        "xml",
        "c",
        "cpp",
        "cmake",
        "proto",
        "hcl",
        "bash",
        "fish",
        "kotlin",
        "r",
        "java",
        "dockerfile",
        "terraform",
        "ssh_config",
        "gitignore",
      },
    },
  },

  {
    "zbirenbaum/copilot.lua",
    cmd = "Copilot",
    event = "InsertEnter",
    config = function()
      require("copilot").setup {
        panel = {
          enabled = false,
        },
        suggestion = {
          enabled = true,
          auto_trigger = true, -- show ghost text as you type
          keymap = {
            accept = "<C-l>", -- avoids clashing with NvChad's <Tab> cmp/luasnip mapping
            accept_word = "<C-;>",
            accept_line = "<C-j>",
            next = "<M-]>",
            prev = "<M-[>", -- NOT <C-[>: that is the same byte as <Esc> and would hijack escape
            dismiss = "<C-h>",
          },
        },
      }
    end,
  },

  {
    "kylechui/nvim-surround",
    event = "VeryLazy",
    config = function()
      require("nvim-surround").setup {
        -- Configuration here, or leave empty to use defaults
      }
    end,
  },

  {
    "saecki/crates.nvim",
    tag = "stable",
    config = function()
      require("crates").setup()
    end,
  },

  {
    "lambdalisue/suda.vim",
    cmd = { "SudaWrite", "SudaRead" },
  },

  {
    "kevinhwang91/nvim-ufo",
    config = function()
      vim.keymap.set("n", "zR", require("ufo").openAllFolds, { desc = "Open all folds" })
      vim.keymap.set("n", "zM", require("ufo").closeAllFolds, { desc = "Close all folds" })
      require("ufo").setup {
        provider_selector = function(bufnr, filetype, buftype)
          return { "lsp", "treesitter" }
        end,
      }
    end,
    dependencies = { "kevinhwang91/promise-async" },
  },
}
