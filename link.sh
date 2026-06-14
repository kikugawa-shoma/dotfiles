#!/bin/bash
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_SRC_DIR="${SCRIPT_DIR}/src"

safe_link(){
	local src="$1"
	local dest="$2"
	# dest に実体（シンボリックリンクではない通常ファイル/ディレクトリ）が存在する場合のみ確認処理へ
	if [ -e "$dest" ] && [ ! -L "$dest" ];then
		# `rm -rf /` や `rm -rf ~` といった破壊的操作を防ぐため、
		# dest を絶対パスに正規化して危険なパスでないか確認する
		local resolved_dest
		resolved_dest="$(readlink -m "$dest")"
		case "$resolved_dest" in
			/|"$HOME")
				echo "Error: refusing to remove '$resolved_dest'" >&2
				return 1
				;;
		esac

		# -n 1: 1文字入力した時点で Enter なしに確定する
		read -n 1 -p "Overwrite existing file/directory '$dest'? [y/N]: " answer
		echo
		case "$answer" in
			[yY])
				rm -rf "$dest"
				;;
			*)
				echo "Skip: $dest"
				return
				;;
		esac
	fi
	ln -snf "$src" "$dest"
	echo "Linked: $dest -> $src"
}

mkdir -p ~/.claude ~/.config/nvim

# tmux
safe_link "$DOTFILES_SRC_DIR/.tmux.conf" ~/.tmux.conf

# claude
safe_link "$DOTFILES_SRC_DIR/.claude/commands" ~/.claude/commands
safe_link "$DOTFILES_SRC_DIR/.claude/hooks" ~/.claude/hooks
safe_link "$DOTFILES_SRC_DIR/.claude/skills" ~/.claude/skills
safe_link "$DOTFILES_SRC_DIR/.claude/settings.json" ~/.claude/settings.json
safe_link "$DOTFILES_SRC_DIR/.claude/user-scripts" ~/.claude/user-scripts

# nvim
safe_link "$DOTFILES_SRC_DIR/.config/nvim" ~/.config/nvim




