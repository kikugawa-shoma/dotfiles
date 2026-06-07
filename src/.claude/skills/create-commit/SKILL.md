---
name: create-commit
description: gitコミットの作成が必要なときに使う。ステージング、コミットメッセージ作成、コミット、プッシュを行う。
model: opus
effort: high
---

# Gitコミット作成

現在のワーキングツリーを元にコミットメッセージを生成し、コミットを作成し、プッシュする。

## ワークフロー

### 1. 現在のワーキングツリーの状態を把握

!`git status`

### 2.1 ステージングされているファイルが存在しない場合

コンテキストを元にステージングすべきファイルを明らかに判断できる場合はそれらのファイルをステージングし、次に進む。

```bash
git add {file1} {file2} ...
```

判断できない場合はユーザーに指示を仰ぐ。


### 2.2 ステージングされているファイルが存在する場合

ステージングされている変更の統計: !`git diff --cached --shortstat`

総変更行数が少ない(500行以下)場合、変更内容を読む。

```bash
git diff --staged
```

総変更行数が多い場合、変更の統計情報をリストした上で、コミットメッセージを書くのに必要十分な情報が集まるまで、変更を選択的に読む。

```bash
git diff --stat --staged
git diff --staged -- {path/to/file}
```

### 3. コミットメッセージを考える

[Conventional Commits](https://www.conventionalcommits.org/en/v1.0.0/) の形式に従い、英語でコミットメッセージを考える。変更内容を最もよく表す `type` を選び、必要に応じて scope・body・footer を加える。

#### フォーマット

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

#### type

- `feat`: 新機能の追加（SemVer の MINOR に対応）
- `fix`: バグ修正（SemVer の PATCH に対応）
- `docs`: ドキュメントのみの変更
- `style`: コードの意味に影響しない変更（空白・フォーマットなど）
- `refactor`: バグ修正や機能追加を伴わないコードの変更
- `perf`: パフォーマンスを改善する変更
- `test`: テストの追加・修正
- `build`: ビルドシステムや依存関係に関する変更
- `ci`: CI の設定やスクリプトの変更
- `chore`: 上記以外の雑多な変更

#### scope（任意）

変更が影響するコードベースの範囲を `()` 内に記述する（例: `fix(parser):`）。

#### description

変更内容の短い要約。命令法・現在形で書く（例: `add`、`fix`。`added`、`fixed` ではない）。

#### body（任意）

description だけでは伝わらない変更の背景・理由・詳細を記述する。description との間に空行を1行入れる。

#### footer（任意）

関連する issue 番号などを `token: value` 形式で記述する（例: `Refs: #123`）。body との間に空行を1行入れる。

#### 破壊的変更（BREAKING CHANGE）

後方互換性を壊す変更がある場合、次のいずれか（または両方）で示す。破壊的変更は SemVer の MAJOR に対応する。

- type / scope の直後、コロンの前に `!` を付ける（例: `feat(api)!: send email when product ships`）
- フッターに `BREAKING CHANGE: <説明>` を記述する

#### 例

```
feat(lang): add Polish language
```

```
fix: prevent racing of requests

Introduce a request id and a reference to latest request.

Refs: #123
```

```
feat!: send an email to the customer when a product is shipped

BREAKING CHANGE: existing clients no longer receive the legacy response format.
```

### 4. コミットする

ステップ3で考えたメッセージでコミットする。複数行になる場合は heredoc を使う。

```bash
git commit -m "$(cat <<'EOF'
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
EOF
)"
```

コミット後、内容を確認する。

```bash
git log -1 --stat
```

### 5. プッシュする

現在のブランチをリモートにプッシュする。

```bash
git push
```

上流ブランチが設定されていない場合は、設定した上でプッシュする。

```bash
git push -u origin HEAD
```

