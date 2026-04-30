#! /usr/bin/env bash

set -euo pipefail

# Finder: 全ての拡張子を表示
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Finder: パスバーを表示
defaults write com.apple.finder ShowPathbar -bool true

# Finder: ステータスバーを表示
defaults write com.apple.finder ShowStatusBar -bool true

# Finder: フルパスをタイトルバーに表示
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Finder: 隠しファイルを表示
defaults write com.apple.finder AppleShowAllFiles -bool true

# Finder: リスト表示をデフォルトに
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Finder: 拡張子変更時の警告を無効化
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Finder: デスクトップにハードディスクを表示しない
defaults write com.apple.finder ShowHardDrivesOnDesktop -bool false

# Dock: アイコンサイズ
defaults write com.apple.dock tilesize -int 48

# Dock: 自動的に隠す
defaults write com.apple.dock autohide -bool true

# Dock: 表示/非表示の遅延をなくす
defaults write com.apple.dock autohide-delay -float 0

# スクリーンショット: 保存先をDesktopに
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# スクリーンショット: ファイル名のプレフィックスを変更 (「スクリーンショット」→「ss」)
defaults write com.apple.screencapture name -string "ss"

# キーリピート速度を速く
defaults write NSGlobalDomain KeyRepeat -int 2

# キーリピート開始までの時間を短く
defaults write NSGlobalDomain InitialKeyRepeat -int 15

# トラックパッド: タップでクリック
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true

# .DS_Store をネットワークボリュームに作成しない
defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

# .DS_Store を USB ボリュームに作成しない
defaults write com.apple.desktopservices DSDontWriteUSBStores -bool true

# Spotlight: インデックス作成を無効化（Raycast で代替）
sudo mdutil -a -i off

# 設定を反映
killall Finder
killall Dock

echo "macOS defaults applied. Some changes may require logout to take effect."
