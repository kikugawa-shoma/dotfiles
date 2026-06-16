local loader = require("config.snippet_loader")

-- グローバル（最下位優先度）のスニペット定義
-- キーがトリガ語、値が展開後の本文（VSCode/LSP形式: $1, ${1:name}, $0）
-- 本文は文字列、または複数行を表す文字列の配列で書ける
-- ディレクトリ単位で上書き・追加したい場合は .nvim-snippets.json を配置する
local snippets = {
  go = {
    ife = { "if err != nil {", "\t$0", "}" },
    main = { "package main", "", "func main() {", "\t$0", "}" },
    fn = "func ${1:name}(${2}) ${3} {\n\t$0\n}",
  },
  lua = {
    fn = "function ${1:name}(${2})\n\t$0\nend",
    req = 'local ${1:mod} = require("${2:mod}")$0',
  },
  typescript = {
    cl = "console.log($0)",
    fn = "function ${1:name}(${2}) {\n\t$0\n}",
  },
}

-- カーソル直前の単語を返す
local function word_before_cursor()
  local col = vim.fn.col(".") - 1
  local line = vim.api.nvim_get_current_line()
  return line:sub(1, col):match("[%w_]+$")
end

-- 本文を文字列に正規化（配列なら改行で連結）
local function to_body(body)
  return type(body) == "table" and table.concat(body, "\n") or body
end

-- <Tab>: スニペット展開 / プレースホルダ間の前進 / 通常のTab
local function expand_or_jump()
  if vim.snippet.active({ direction = 1 }) then
    return vim.snippet.jump(1)
  end

  -- グローバル定義にディレクトリ定義をマージした結果を使う
  local resolved = loader.resolve(vim.api.nvim_get_current_buf(), snippets)
  local ft_snippets = resolved[vim.bo.filetype]
  local word = word_before_cursor()
  if ft_snippets and word and ft_snippets[word] then
    -- トリガ語を削除してから展開する
    local col = vim.fn.col(".") - 1
    vim.api.nvim_buf_set_text(0, vim.fn.line(".") - 1, col - #word, vim.fn.line(".") - 1, col, { "" })
    vim.snippet.expand(to_body(ft_snippets[word]))
    return
  end

  -- どれにも該当しなければ通常のTabを挿入する
  vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<Tab>", true, false, true), "n", false)
end

-- <S-Tab>: プレースホルダ間の後退
local function jump_back()
  if vim.snippet.active({ direction = -1 }) then
    vim.snippet.jump(-1)
  end
end

loader.setup()

vim.keymap.set("i", "<Tab>", expand_or_jump, { desc = "スニペット展開 / 次のプレースホルダ" })
vim.keymap.set({ "i", "s" }, "<S-Tab>", jump_back, { desc = "前のプレースホルダ" })
