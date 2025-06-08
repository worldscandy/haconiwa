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