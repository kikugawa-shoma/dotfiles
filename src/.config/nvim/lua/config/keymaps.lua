vim.g.mapleader = " "

vim.keymap.set("i", "\'", "\'\'<Left>")
vim.keymap.set("i", "\"", "\"\"<Left>")
-- vim.keymap.set("i", "<", "<><Left>")
vim.keymap.set("i", "{", "{}<Left>")
vim.keymap.set("i", "[", "[]<Left>")
vim.keymap.set("i", "(", "()<Left>")

vim.keymap.set("i", "{<Enter>", "{}<Left><Enter><Up><Esc>o")
vim.keymap.set("i", "[<Enter>", "[]<Left><Enter><Up><Esc>o")
vim.keymap.set("i", "(<Enter>", "()<Left><Enter><Up><Esc>o")

