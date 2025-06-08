# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## プロジェクト概要

Haconiwa（箱庭）は、AI協調開発支援Python CLIツールです。tmux環境での多Agent管理、git-worktree統合、タスク管理、AIエージェント調整を提供します。

## 開発用コマンド

### インストールと実行
```bash
# 開発環境でのインストール
pip install -e .

# メインCLI実行
haconiwa

# テスト実行 
pytest --cov=src --cov-report=html

# コード品質チェック（リンティング、フォーマット、型チェック、セキュリティスキャン）
./scripts/lint.sh
```

### プロジェクト固有コマンド
```bash
# テストランナー
haconiwa-test

# プリリリースチェック
haconiwa-prerelease

# tmux多Agent環境作成（4x4レイアウト）
haconiwa company multiagent --name my-project --base-path /path/to/desks

# Company管理
haconiwa company list
haconiwa company attach <company-name>
haconiwa company kill <company-name>
```

## アーキテクチャ

### 階層構造
- **Company（会社）**: tmux Session に対応する最上位管理単位
- **Room（部屋）**: tmux Window に対応する機能別作業エリア
- **Desk（机）**: tmux Pane に対応する個別ワークスペース
- **Building/Floor**: tmux非依存の論理管理層

### コアモジュール構成
- `haconiwa.cli`: メインCLIエントリーポイント
- `haconiwa.core`: 設定、ログ、状態管理
- `haconiwa.space`: tmux Company管理（space/cli.py が中心）
- `haconiwa.agent`: Boss/Worker/Manager エージェント管理
- `haconiwa.task`: git-worktree統合タスク管理
- `haconiwa.resource`: データベース・ファイルパススキャン
- `haconiwa.watch`: リアルタイムモニタリング
- `haconiwa.world`: 開発環境プロバイダー（Docker/Local）

### 重要な実装詳細
- すべてのサブコマンドは `typer.Typer()` で構築され、メインCLIに `app.add_typer()` で追加
- tmux統合は `libtmux` ライブラリ経由で実装
- 設定管理は `haconiwa.core.config.Config` クラス
- 4x4多Agent環境は組織（org-01〜04）× 役割（boss, worker-a/b/c）の16ペイン構成

### 開発時の重要な注意点
- `scripts/lint.sh` は black, flake8, mypy, bandit, isort を順次実行
- テストは pytest でカバレッジ測定込み
- エージェント機能は開発中のため、プレースホルダー実装多数
- tmux Company機能は完全実装済み（作成・一覧・アタッチ・削除・ディレクトリクリーンアップ）

### プロジェクト状態
- バージョン: 0.2.2（PyPI公開準備中）
- ライセンス: MIT
- Python対応: 3.8+
- 開発ステータス: Alpha開発中

## 他プロジェクトでの使用方法

### グローバルインストール
```bash
# PyPIからグローバルインストール（推奨）
pip install --user haconiwa

# または開発版を使用
pip install --user haconiwa==0.2.2
```

グローバルインストール後は、任意のディレクトリで`haconiwa`コマンドが使用可能。

### 基本的な使用パターン
```bash
# 任意のリポジトリディレクトリに移動
cd /path/to/your/repository

# worktreeディレクトリで多Agent環境を作成
haconiwa company multiagent \
  --name project-name \
  --base-path ./worktree \
  --org01-name "Frontend" --task01 "UI Development" \
  --org02-name "Backend" --task02 "API Development" \
  --org03-name "Testing" --task03 "QA Testing" \
  --org04-name "DevOps" --task04 "CI/CD" \
  --no-attach

# 作業開始
haconiwa company attach project-name

# 作業終了後のクリーンアップ
haconiwa company kill project-name --clean-dirs --base-path ./worktree --force
```

### セットアップスクリプト（setup-haconiwa.sh）
プロジェクトで効率的に使用するための自動化スクリプト:

```bash
#!/bin/bash
# setup-haconiwa.sh - プロジェクト用Haconiwa環境セットアップスクリプト

PROJECT_NAME=${1:-$(basename $(pwd))}
BASE_PATH=${2:-"./worktree"}

echo "🚀 Setting up Haconiwa environment for: $PROJECT_NAME"
echo "📁 Base path: $BASE_PATH"

# 既存のcompanyをチェック
if haconiwa company list | grep -q "$PROJECT_NAME"; then
    echo "⚠️  Company '$PROJECT_NAME' already exists"
    read -p "Kill existing company and recreate? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        haconiwa company kill "$PROJECT_NAME" --clean-dirs --base-path "$BASE_PATH" --force
    else
        echo "Attaching to existing company..."
        haconiwa company attach "$PROJECT_NAME"
        exit 0
    fi
fi

# 新しいcompanyを作成
haconiwa company multiagent \
    --name "$PROJECT_NAME" \
    --base-path "$BASE_PATH" \
    --org01-name "Frontend" --task01 "UI/UX Development" \
    --org02-name "Backend" --task02 "API & Logic" \
    --org03-name "Testing" --task03 "QA & Testing" \
    --org04-name "DevOps" --task04 "Build & Deploy" \
    --no-attach

echo "✅ Haconiwa environment created successfully!"
echo "🔗 To attach: haconiwa company attach $PROJECT_NAME"
echo "💀 To cleanup: haconiwa company kill $PROJECT_NAME --clean-dirs --base-path $BASE_PATH --force"
```

**使用方法:**
```bash
# スクリプトを実行可能にする
chmod +x setup-haconiwa.sh

# プロジェクトディレクトリで実行
./setup-haconiwa.sh my-project ./worktree
```

### プロジェクト別カスタマイズ例
```bash
# React/Next.jsプロジェクト
haconiwa company multiagent \
    --name react-app \
    --org01-name "Components" --task01 "UI Components" \
    --org02-name "Pages" --task02 "Page Development" \
    --org03-name "API" --task03 "API Integration" \
    --org04-name "Styling" --task04 "CSS/Tailwind"

# Python/Django プロジェクト  
haconiwa company multiagent \
    --name django-api \
    --org01-name "Models" --task01 "Database Design" \
    --org02-name "Views" --task02 "API Endpoints" \
    --org03-name "Tests" --task03 "Unit/Integration Tests" \
    --org04-name "Deploy" --task04 "Docker/K8s"
```

### マルチプロジェクト管理
```bash
# 複数プロジェクトの同時管理
haconiwa company list                    # 全プロジェクト確認
haconiwa company attach web-frontend     # 特定プロジェクトにアタッチ
haconiwa company kill old-project --force # 不要なプロジェクト削除
```

### 既知の問題

#### ~~PyPI パッケージの依存関係不足~~ (v0.2.2で修正済み)
**問題**: READMEでは `pip install haconiwa` ですぐに利用可能とあるが、実際は依存関係が不足していた

**修正状況**: v0.2.2で以下の不足していた依存関係をすべて追加済み:
- `watchdog>=3.0.0` (ファイル監視)
- `cryptography>=3.4.8` (暗号化)  
- `psutil>=5.8.0` (システム情報)
- `pydantic>=1.8.0` (データ検証)
- `sqlalchemy>=1.4.0` (データベースORM)
- `pandas>=1.3.0` (データ解析)
- `matplotlib>=3.3.0` (グラフ作成)
- `packaging>=20.0` (バージョン管理)