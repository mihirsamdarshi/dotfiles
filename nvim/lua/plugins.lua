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
    use 'neovim/nvim-lspconfig' 
    
    -- Language plugins
    use 'simrat39/rust-tools.nvim'

    -- Completion framework:
    use 'hrsh7th/nvim-cmp' 

    -- LSP completion source:
    use 'hrsh7th/cmp-nvim-lsp'

    -- Useful completion sources:
    use 'hrsh7th/cmp-nvim-lua'
    use 'hrsh7th/cmp-nvim-lsp-signature-help'
    use 'hrsh7th/cmp-vsnip'                             
    use 'hrsh7th/cmp-path'                              
    use 'hrsh7th/cmp-buffer'                            
    use 'hrsh7th/vim-vsnip'

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
    
    -- Highlight function arguments
    use {
        'm-demare/hlargs.nvim',
        requires = { 'nvim-treesitter/nvim-treesitter' }
    }

    -- Make commenting easier
    use {
        'numToStr/Comment.nvim',
        config = function()
            require('Comment').setup()
        end
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


