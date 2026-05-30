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

    end,
  }
}
