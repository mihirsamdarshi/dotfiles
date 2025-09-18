-- EXAMPLE
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

local servers = {
  html = {},
  cssls = {},
  rust_analyzer = {},
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
        },
      },
    },
  },
  sourcekit = {
    root_dir = lspconfig.util.root_pattern(".git", "Package.swift", "compile_commands.json"),
  },
  bashls = {},
  docker_compose_language_service = {},
  dockerls = {},
  gh_actions_ls = {},
  yamlls = {},
  ts_ls = {},
  ruff = {},
  r_language_server = {},
  terraformls = {},
  ty = {},
}

-- lsps with default config
for name, opts in pairs(servers) do
  vim.lsp.enable(name) -- nvim v0.11.0 or above required
  vim.lsp.config(name, opts) -- nvim v0.11.0 or above required
end
