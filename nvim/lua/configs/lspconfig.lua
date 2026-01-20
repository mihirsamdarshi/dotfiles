-- EXAMPLE
require("nvchad.configs.lspconfig").defaults()

local lspconfig = require "lspconfig"

local servers = {
  -- Web Dev
  html = {},
  cssls = {},
  ts_ls = {},
  eslint = {},
  tailwindcss = {},
  -- Serde/config
  jsonls = {},
  yamlls = {},
  -- Python
  pyright = {
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
        },
      },
    },
  },
  ruff = {},
  ty = {},
  -- Rust/C
  rust_analyzer = {},
  sourcekit = {
    root_dir = lspconfig.util.root_pattern(".git", "Package.swift", "compile_commands.json"),
  },
  -- Scripting
  bashls = {},
  just = {},
  -- Analysis
  sqruff = {},
  r_language_server = {},
  -- Infra
  terraformls = {},
  docker_compose_language_service = {},
  dockerls = {},
  gh_actions_ls = {},
  -- Other
  marksman = {},
  stylua = {},
  lua_ls = {},
  home_assistant = {},
}

-- lsps with default config
for name, opts in pairs(servers) do
  vim.lsp.enable(name) -- nvim v0.11.0 or above required
  vim.lsp.config(name, opts) -- nvim v0.11.0 or above required
end
