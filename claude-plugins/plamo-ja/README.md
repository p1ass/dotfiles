# plamo-ja

Claude Codeに英語で返答させ、画面にはローカルのPLaMo 3 Translateで訳した日本語を表示するmod。会話履歴は英語のまま残る。

## 仕組み

- system promptのLanguageセクションと毎回のプロンプトに「英語で返答する」指示を足す
- 返答は段落ごとに `llama-server` の `/v1/completions` へPFML3形式で送って訳す。コードブロックは訳さない
- 訳文は `$.store` に最大3000段落まで保存し、resumeや再起動のあとも使い回す
- Stopフックに渡る `last_assistant_message` も日本語に差し替えるので、通知も日本語になる
- 翻訳サーバーが落ちていれば `llama-server` を自動起動する。`ggufPath` のファイルがなければ `hfRepo` を `-hf` でダウンロードする

## セットアップ

```sh
brew install llama.cpp
claude plugin marketplace add ~/ghq/github.com/p1ass/dotfiles/claude-plugins
claude plugin install plamo-ja@p1ass-dotfiles
```

`script/setup_claude_plugins.sh` が同じことをする。

## 使い方

- `/plamo on|off` で翻訳を切り替える。オフにすると日本語で返答する
- `/config` で `endpoint`・`form`（polite / plain）・`context`・`ggufPath`・`hfRepo` を変える

モデルはPLaMo Community Licenseに従う。
