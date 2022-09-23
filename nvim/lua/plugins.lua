vim.cmd [[packadd packer.nvim]]

return require('packer').startup(function()
    use 'wbthomason/packer.nvim'
    
    -- Manage LSPs
    use { 
        'williamboman/mason.nvim',
        config = function() require("mason").setup() end
    }
    use {
        'williamboman/mason-lspconfig.nvim',
        config = function() require("mason-lspconfig").setup({
            ensure_installed = { "sumneko_lua", "rust_analyzer", "tsserver", "pyright" }
        }) end
    }
   
    use { -- A collection of common configurations for Neovim's built-in language server client
          'neovim/nvim-lspconfig',
          config = [[ require('plugins/lspconfig') ]]
    }

    use { -- vscode-like pictograms for neovim lsp completion items Topics
          'onsails/lspkind-nvim',
          config = [[ require('plugins/lspkind') ]]
    }

    use { -- Utility functions for getting diagnostic status and progress messages from LSP servers, for use in the Neovim statusline
          'nvim-lua/lsp-status.nvim',
          config = [[ require('plugins/lspstatus') ]]
    }

    -- Language plugins
    use 'simrat39/rust-tools.nvim'

    use { -- A completion framework for neovim
        'hrsh7th/nvim-cmp',
        requires = {
            "hrsh7th/cmp-nvim-lsp",           -- nvim-cmp source for neovim builtin LSP client
            'hrsh7th/cmp-nvim-lsp-signature-help',
            "hrsh7th/cmp-nvim-lua",           -- nvim-cmp source for nvim lua
            "hrsh7th/cmp-buffer",             -- nvim-cmp source for buffer words.
            "hrsh7th/cmp-path",               -- nvim-cmp source for filesystem paths.
            "hrsh7th/cmp-calc",               -- nvim-cmp source for math calculation.
            'hrsh7th/vim-vsnip'
        },
        config = [[ require('plugins/cmp') ]],
    }

    -- Tree-sitter
    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate'
    }
    -- Color Scheme
    use 'tanvirtin/monokai.nvim'

    -- Speed up load times
    use 'lewis6991/impatient.nvim'

    -- Telescope
    use {
      'nvim-telescope/telescope.nvim', tag = '0.1.0',
      requires = { {'nvim-lua/plenary.nvim'} }
    }
    
    -- Autopairs
    use {
	    'windwp/nvim-autopairs',
        config = function() require('nvim-autopairs').setup {} end
    }
    
    -- Add panel for viewing issues
    use {
        'folke/trouble.nvim',
        requires = 'kyazdani42/nvim-web-devicons',
        config = function() require('trouble').setup {} end
    }

    -- Add TeX support
    use 'lervag/vimtex'
    
    -- Highlight function arguments
    use {
        'm-demare/hlargs.nvim',
        requires = { 'nvim-treesitter/nvim-treesitter' }
    }

    -- Make commenting easier
    use {
        'numToStr/Comment.nvim',
        config = function() require('Comment').setup() end
    }

    -- Auto-indent blank lines
    use "lukas-reineke/indent-blankline.nvim"
    
    -- Automatic highlighting of other occurrences of a word in a cmp-buffer
    use 'RRethy/vim-illuminate'

    use {
        "folke/which-key.nvim",
        config = function() require("which-key").setup {} end
    }
end)


