-- EXAMPLE
local on_attach = require("nvchad.configs.lspconfig").on_attach
local on_init = require("nvchad.configs.lspconfig").on_init
local capabilities = require("nvchad.configs.lspconfig").capabilities

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
  yamlls = {},
  ruff_lsp = {},
  r_language_server = {},
}

-- lsps with default config
for lsp, opts in pairs(servers) do
  opts.on_init = on_init
  opts.on_attach = on_attach
  opts.capabilities = capabilities

  lspconfig[lsp].setup {
    on_attach = on_attach,
    on_init = on_init,
    capabilities = capabilities,
  }
end

-- typescript
lspconfig.tsserver.setup {
  on_attach = on_attach,
  on_init = on_init,
  capabilities = capabilities,
}
