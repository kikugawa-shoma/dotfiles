-- スニペット展開のプレビューを表示するモジュール
-- 挿入モードでカーソル直前の語がトリガと完全一致したとき、
-- <Tab> で展開される完成形を現在行の下にゴースト行として表示する
local loader = require("config.snippet_loader")

local M = {}

local ns = vim.api.nvim_create_namespace("SnippetHint")

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

-- プレースホルダをプレビュー用に整形する
-- ${1:default} はデフォルト値を残し、${1} や $1/$0 は除去する
local function to_preview(body)
  body = body:gsub("%${%d+:([^}]*)}", "%1") -- ${1:default} -> default
  body = body:gsub("%${%d+}", "") -- ${1} -> ""
  body = body:gsub("%$%d+", "") -- $1 / $0 -> ""
  return body
end

-- 現在のカーソル位置に対してプレビューを張り替える
local function update()
  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  local ft_snippets = loader.resolve(buf, M.base)[vim.bo.filetype]
  if not ft_snippets then
    return
  end

  local word = word_before_cursor()
  if not word or not ft_snippets[word] then
    return
  end

  -- 完成形を行ごとのゴースト行(virt_lines)に変換する
  local virt_lines = {}
  for line in (to_preview(to_body(ft_snippets[word])) .. "\n"):gmatch("(.-)\n") do
    table.insert(virt_lines, { { line, "SnippetGhost" } })
  end

  vim.api.nvim_buf_set_extmark(buf, ns, vim.fn.line(".") - 1, 0, {
    virt_lines = virt_lines,
    virt_lines_above = false,
  })
end

-- base: グローバルのスニペット定義（loader.resolveへ渡す）
function M.setup(base)
  M.base = base

  -- ゴースト行のハイライト（既定はComment。ユーザーが上書き可能）
  vim.api.nvim_set_hl(0, "SnippetGhost", { link = "Comment", default = true })

  local group = vim.api.nvim_create_augroup("SnippetHint", { clear = true })
  vim.api.nvim_create_autocmd({ "TextChangedI", "CursorMovedI" }, {
    group = group,
    callback = update,
  })
  vim.api.nvim_create_autocmd("InsertLeave", {
    group = group,
    callback = function()
      vim.api.nvim_buf_clear_namespace(vim.api.nvim_get_current_buf(), ns, 0, -1)
    end,
  })
end

return M
