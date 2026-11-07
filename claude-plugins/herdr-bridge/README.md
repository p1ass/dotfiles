# herdr-bridge

herdrのサイドバーに、Claude Codeの承認待ちと実行中のサブエージェント数を表示するmod。

## 仕組み

- herdrはClaudeの状態を画面から判定し、`herdr pane report-agent` で送った状態を使わない。そのため状態は変えず、表示専用の `$cc` トークンを `herdr pane report-metadata` で送る
- 権限の確認や `AskUserQuestion` が出ている間は `needs approval`、サブエージェントが動いている間は `N agents` を送り、どちらでもなければ消す
- herdrの外（`HERDR_ENV` が `1` でない）では何もしない

## セットアップ

```sh
claude plugin marketplace add ~/ghq/github.com/p1ass/dotfiles/claude-plugins
claude plugin install herdr-bridge@p1ass-dotfiles
```

`script/setup_claude_plugins.sh` が同じことをする。表示する行は `.config/herdr/config.toml` の `rows_by_agent` に `{ token = "$cc" }` として書いてある。
