local options = {
    smartindent = true,
    tabstop = 2,
    shiftwidth = 2,
    showtabline = 2,
    number = true,
		mouse = "a",
		timeoutlen = 500,
}

for k, v in pairs(options) do
    vim.opt[k] = v
end

