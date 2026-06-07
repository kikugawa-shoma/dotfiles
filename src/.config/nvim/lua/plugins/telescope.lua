return {
  { 
    "nvim-telescope/telescope.nvim", 
    opts = {},
    config = function()
      require('telescope').setup({
        defaults = {
          -- .git ディレクトリ配下は検索対象から除外する
          file_ignore_patterns = { '^.git/' },
        },
        pickers = {
          find_files = {
            -- ドットファイルなどの隠しファイルも検索対象に含める
            hidden = true,
          },
          live_grep = {
            -- 隠しファイルを検索しつつ .git 配下は除外する
            additional_args = { '--hidden', '--glob=!**/.git/*' },
          },
        },
      })

      local builtin = require('telescope.builtin')
      vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
      vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
      vim.keymap.set('n', '<leader>fb', builtin.buffers, { desc = 'Telescope buffers' })
      vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
    end,
  }
}
