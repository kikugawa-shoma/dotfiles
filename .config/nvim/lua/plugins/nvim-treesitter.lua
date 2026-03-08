local pattern = { 
  'typescript',
  'javascript',
  'c',
  'cpp',
  'bash',
  'tsx',
  'jsx',
  'go',
  'lua' 
}


return 
{
  {
    'nvim-treesitter/nvim-treesitter',
    lazy = false,
    build = ':TSUpdate',
    opts = {},
  	config = function()
			local ts = require('nvim-treesitter')
			ts.setup({
				highlight = { enable = true }
			})
			ts.install(pattern)
			vim.api.nvim_create_autocmd('FileType', {
				pattern = pattern,
        callback = function()
          vim.treesitter.start()
					vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
					-- vim.wo[0][0].foldexpr = 'v:lua.vim.treesitter.foldexpr()'
					-- vim.wo[0][0].foldmethod = 'expr'
        end,
      })
		end,
  }
}

