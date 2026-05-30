local options = {
  smartindent = true,   -- 新しい行に自動インデント（コード構造を認識）
  tabstop = 2,          -- タブ文字を2スペース幅で表示
  shiftwidth = 2,       -- >>やオートインデントのスペース数
  shiftround = true,    -- インデントをshiftwidthの倍数に丸める
  showtabline = 2,      -- タブラインを常に表示
  number = true,        -- 行番号を表示
  mouse = "a",          -- 全モードでマウス操作を有効化
  timeoutlen = 500,     -- キーシーケンスの入力待ち時間（ms）
  expandtab = true,     -- Tabキー入力をスペースに展開
  scrolloff = 10,
}

for k, v in pairs(options) do
  vim.opt[k] = v
end

