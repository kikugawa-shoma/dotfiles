-- 有効化する言語サーバーの一覧（別途インストールが必要）
local servers = {
  "ts_ls",      -- typescript / javascript / tsx / jsx
  "clangd",     -- c / cpp
  "bashls",     -- bash
  "gopls",      -- go
  "lua_ls",     -- lua
}

return {
  {
    "neovim/nvim-lspconfig",
    -- ファイルを開くタイミングまでロードを遅延し、起動を高速化
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- 各言語サーバーを有効化（Neovim 0.11+ の新API）
      for _, server in ipairs(servers) do
        vim.lsp.enable(server)
      end

      -- LSPがバッファにアタッチされた時にのみ、そのバッファ用のキーマップを設定する
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local bufnr = args.buf
          local opts = { buffer = bufnr }
          -- コードジャンプ系
          vim.keymap.set("n", "gd", vim.lsp.buf.definition, opts)       -- 定義へジャンプ
          vim.keymap.set("n", "gD", vim.lsp.buf.declaration, opts)      -- 宣言へジャンプ
          vim.keymap.set("n", "gi", vim.lsp.buf.implementation, opts)   -- 実装へジャンプ
          vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)       -- 参照を一覧
          -- ドキュメント・リファクタ系
          vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)             -- ホバー情報を表示
          vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)   -- シンボルのリネーム
          vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts) -- コードアクション
          -- フォーマット（非同期、明示的に呼び出す用）
          vim.keymap.set("n", "<leader>f", function()
            vim.lsp.buf.format({ async = true })
          end, opts)
          -- 診断（エラー・警告）の移動と表示
          vim.keymap.set("n", "[d", vim.diagnostic.goto_prev, opts)     -- 前の診断へ
          vim.keymap.set("n", "]d", vim.diagnostic.goto_next, opts)     -- 次の診断へ
          vim.keymap.set("n", "<leader>e", vim.diagnostic.open_float, opts) -- 診断をフロート表示
        end,
      })

      -- 診断（エラー・警告）の表示方法
      vim.diagnostic.config({
        virtual_text = true,       -- 行末に診断メッセージを表示
        signs = true,              -- 行番号横にサインを表示
        underline = true,          -- 該当箇所に下線
        update_in_insert = false,  -- 挿入モード中は更新しない（チラつき防止）
        severity_sort = true,      -- 重大度順にソート
      })

      -- Goファイルは保存直前に自動フォーマット（goplsを使用）
      -- async=false にしないと保存処理に間に合わない
      vim.api.nvim_create_autocmd("BufWritePre", {
        pattern = "*.go",
        callback = function()
          vim.lsp.buf.format({ async = false })
        end,
      })
    end,
  },
}
