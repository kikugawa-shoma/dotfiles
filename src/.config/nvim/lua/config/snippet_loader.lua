-- ディレクトリ単位のスニペット定義をカスケード解決するモジュール
-- 編集中ファイルのディレクトリからgitルートまで .nvim-snippets.json を上方向に探索し、
-- root→leaf の順でマージする（同名triggerは近い側＝leafが勝つ）
local M = {}

local DEF_NAME = ".nvim-snippets.json"

-- bufnr -> マージ済みスニペットテーブルのキャッシュ
local cache = {}

-- baseを2階層コピーして元テーブルを汚さないようにする
local function copy_base(base)
  local result = {}
  for ft, entries in pairs(base) do
    local t = {}
    for trigger, body in pairs(entries) do
      t[trigger] = body
    end
    result[ft] = t
  end
  return result
end

-- 1ファイル分の定義をresultへマージする（同名triggerは後勝ち）
local function merge(result, defs)
  for ft, entries in pairs(defs) do
    if type(entries) == "table" then
      result[ft] = result[ft] or {}
      for trigger, body in pairs(entries) do
        result[ft][trigger] = body
      end
    end
  end
end

-- JSONを読み込んでテーブルを返す（失敗時はnilを返し警告する）
local function read_json(path)
  local ok, lines = pcall(vim.fn.readfile, path)
  if not ok then
    return nil
  end
  local ok2, decoded = pcall(vim.json.decode, table.concat(lines, "\n"))
  if not ok2 or type(decoded) ~= "table" then
    vim.notify(("スニペット定義の読み込みに失敗: %s"):format(path), vim.log.levels.WARN)
    return nil
  end
  return decoded
end

-- gitルートのディレクトリを返す（見つからなければnil）
local function git_root(dir)
  local gitdir = vim.fs.find(".git", { upward = true, path = dir, limit = 1 })[1]
  return gitdir and vim.fs.dirname(gitdir) or nil
end

-- 指定バッファに適用するスニペットテーブルを返す
-- base: グローバル定義（最下位の優先度として使う）
function M.resolve(buf, base)
  if cache[buf] then
    return cache[buf]
  end

  local path = vim.api.nvim_buf_get_name(buf)
  local result = copy_base(base)

  -- git管理下のファイルのときだけディレクトリ定義を探索する
  if path ~= "" then
    local dir = vim.fs.dirname(path)
    local root = git_root(dir)
    if root then
      local found = vim.fs.find(DEF_NAME, {
        upward = true,
        path = dir,
        stop = vim.fs.dirname(root), -- gitルート自身も探索対象に含めるため親を停止境界にする
        limit = math.huge,
      })
      -- foundは近い順。root→leafでマージしたいので逆順に適用する
      for i = #found, 1, -1 do
        local defs = read_json(found[i])
        if defs then
          merge(result, defs)
        end
      end
    end
  end

  cache[buf] = result
  return result
end

-- キャッシュ無効化用のautocmdを登録する
function M.setup()
  local group = vim.api.nvim_create_augroup("DirSnippetsCache", { clear = true })
  -- 定義ファイルを保存したら全バッファのキャッシュを破棄して次回再解決させる
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = group,
    pattern = DEF_NAME,
    callback = function()
      cache = {}
    end,
  })
  -- バッファ破棄時にキャッシュを掃除する
  vim.api.nvim_create_autocmd({ "BufDelete", "BufWipeout" }, {
    group = group,
    callback = function(ev)
      cache[ev.buf] = nil
    end,
  })
end

return M
