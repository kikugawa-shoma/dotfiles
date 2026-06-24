return 
{
  { "nvim-tree/nvim-web-devicons", opts = {} },
  {
    "nvim-tree/nvim-tree.lua",
    config = function()
      vim.opt.termguicolors = true
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
      local nvimTree = require("nvim-tree")
      nvimTree.setup()
      local api = require("nvim-tree.api")
      vim.keymap.set("n", "<leader>tt", api.tree.toggle)
      vim.keymap.set("n", "<leader>to", api.tree.open)
			vim.keymap.set("n", "<leader>t?", api.tree.toggle_help)

      -- ファイル側を:qで閉じてツリーだけが残る場合、ツリーも一緒に閉じる
      -- https://github.com/nvim-tree/nvim-tree.lua/wiki/Auto-Close (@ppwwyyxx版)
      vim.api.nvim_create_autocmd("QuitPre", {
        callback = function()
          local tree_wins = {}
          local floating_wins = {}
          local wins = vim.api.nvim_list_wins()
          for _, w in ipairs(wins) do
            local bufname = vim.api.nvim_buf_get_name(vim.api.nvim_win_get_buf(w))
            if bufname:match("NvimTree_") ~= nil then
              table.insert(tree_wins, w)
            end
            if vim.api.nvim_win_get_config(w).relative ~= "" then
              table.insert(floating_wins, w)
            end
          end
          if 1 == #wins - #floating_wins - #tree_wins then
            for _, w in ipairs(tree_wins) do
              vim.api.nvim_win_close(w, true)
            end
          end
        end,
      })

    end,
  }
}
