#! /usr/bin/env zsh

set -uo pipefail

chsh -s "$(which zsh)"

ZPREZTO_DIR="${ZDOTDIR:-$HOME}/.zprezto"

if [[ ! -d "$ZPREZTO_DIR" ]]; then
    git clone --recursive https://github.com/sorin-ionescu/prezto.git "$ZPREZTO_DIR"
else
    cd "$ZPREZTO_DIR"
    git pull || true
    git submodule sync --recursive
    git submodule update --init --recursive
    cd - > /dev/null
fi

# pure テーマのシンボリックリンクを確認・作成
if [[ -f "$ZPREZTO_DIR/modules/prompt/external/pure/pure.zsh" ]]; then
    ln -sf "$ZPREZTO_DIR/modules/prompt/external/pure/pure.zsh" \
           "$ZPREZTO_DIR/modules/prompt/functions/prompt_pure_setup"
    ln -sf "$ZPREZTO_DIR/modules/prompt/external/pure/async.zsh" \
           "$ZPREZTO_DIR/modules/prompt/functions/async"
    echo "pure theme linked successfully"
else
    echo "WARNING: pure.zsh not found. Run 'git submodule update --init --recursive' in $ZPREZTO_DIR"
fi

# prezto の runcoms をリンク
setopt EXTENDED_GLOB
for rcfile in "$ZPREZTO_DIR"/runcoms/^README.md(.N); do
    ln -sf "$rcfile" "${ZDOTDIR:-$HOME}/.${rcfile:t}"
done
