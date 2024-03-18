return {
  {
    "stevearc/conform.nvim",
    event = "BufWritePre", -- uncomment for format on save
    config = function()
      require "configs.conform"
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
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        "lua-language-server",
        "stylua",
        "html-lsp",
        "css-lsp",
        "prettier",
        "bash-language-server",
        "beautysh",
        "biome",
        "buf",
        "clang-format",
        "cmake-language-server",
        "docker-compose-language-service",
        "dockerfile-language-server",
        "fixjson",
        "gradle-language-server",
        "hclfmt",
        "json-lsp",
        "ktlint",
        "marksman",
        "pyright",
        "r-languageserver",
        "ruff",
        "ruff-lsp",
        "rust-analyzer",
        "shellcheck",
        "shellharden",
        "taplo",
        "terraform-ls",
        "tflint",
        "typescript-language-server",
        "vscode-solidity-server",
        "yaml-language-server",
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
        "yaml",
        "c",
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
}
