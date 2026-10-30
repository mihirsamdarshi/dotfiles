local options = {
  formatters_by_ft = {
    lua = { "stylua" },
    css = { "prettier" },
    html = { "prettier" },
    python = { "ruff_fix", "ruff_format" },
    sh = { "shfmt" },
    rust = { "rustfmt" },
    r = { "styler" },
    rmd = { "styler" },
    c = { "clang_format" },
    cpp = { "clang_format" },
    proto = { "buf" },
    kotlin = { "ktlint" },
    hcl = { "hcl" }, -- runs hclfmt
  },

  format_on_save = {
    -- These options will be passed to conform.format()
    timeout_ms = 500,
    lsp_format = "fallback",
  },
}

require("conform").setup(options)
