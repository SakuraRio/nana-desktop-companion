#!/bin/bash
# ============================================================
# Nana Desktop Companion - 版本快照管理工具
# 用法:
#   ./snapshot.sh              # 查看所有版本
#   ./snapshot.sh save "说明"  # 创建新版本存档（自动打 tag + 更新日志）
#   ./snapshot.sh rollback     # 交互式选择版本回退
#   ./snapshot.sh latest       # 回到最新 main 分支
# ============================================================

set -e
cd "$(dirname "$0")"
PROJECT_DIR=$(pwd)
CHANGELOG="CHANGELOG.md"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

echo ""
echo -e "${CYAN}============================================${NC}"
echo -e "${CYAN}  Nana Desktop Companion - 版本管理${NC}"
echo -e "${CYAN}============================================${NC}"
echo ""

# --- 命令: 无参数 = 列出所有版本 ---
if [ $# -eq 0 ]; then
    echo -e "${BLUE}已存档的版本：${NC}"
    echo "----------------------------------------"

    TAGS=$(git tag -l 'v*' --sort=-version:refname 2>/dev/null | head -20)
    if [ -z "$TAGS" ]; then
        echo -e "${YELLOW}(暂无版本存档，使用 ./snapshot.sh save \"说明\" 创建)${NC}"
        echo ""
        exit 0
    fi

    IDX=0
    for tag in $TAGS; do
        IDX=$((IDX + 1))
        COMMIT=$(git log -1 --format='%h' "$tag" 2>/dev/null || echo "?")
        DATE=$(git log -1 --format='%ai' "$tag" 2>/dev/null | cut -d' ' -f1-3)
        MSG=$(git log -1 --format='%s' "$tag" 2>/dev/null)
        # 提取 changelog 中对应版本的详细描述
        DESC=$(sed -n "/^## ${tag}/,/^## /p" "$CHANGELOG" 2>/dev/null | sed '1d;$d' | head -6 | sed 's/^/         /')
        if [ -z "$DESC" ]; then
            DESC="         (详见 CHANGELOG.md)"
        fi

        echo -e " ${GREEN}[${tag}]${NC}  ${DATE}  (${COMMIT})"
        echo -e "         ${MSG}"
        echo "$DESC"
        echo ""
    done

    echo -e "当前分支: $(git branch --show-current)"
    echo -e "最新 commit: $(git log -1 --oneline)"
    echo ""

    echo "命令:"
    echo -e "  ${CYAN}./snapshot.sh save \"修复了xxx bug\"${NC}  — 创建新存档"
    echo -e "  ${CYAN}./snapshot.sh rollback${NC}             — 选择版本回退"
    echo -e "  ${CYAN}./snapshot.sh latest${NC}               — 回到最新版"
    echo ""
    exit 0
fi

# --- 命令: save ---
if [ "$1" = "save" ]; then
    MSG="${2:-$(date '+%Y-%m-%d 自动存档')}"

    # 确保工作区干净
    if ! git diff --quiet 2>/dev/null || ! git diff --cached --quiet 2>/dev/null; then
        echo -e "${YELLOW}检测到未提交的更改，先自动提交...${NC}"
        git add -A
        git commit -m "chore: auto-commit before snapshot - ${MSG}" --allow-empty
    fi

    # 计算新版本号（基于现有 tag 数量）
    LAST_NUM=$(git tag -l 'v*' --sort=-v:refname 2>/dev/null | head -1 | sed 's/v//' | cut -d. -f2)
    NEW_NUM=$((LAST_NUM + 1))
    NEW_TAG="v1.${NEW_NUM}"

    # 如果已有这个 tag，跳过
    if git rev-parse "$NEW_TAG" >/dev/null 2>&1; then
        echo -e "${YELLOW}${NEW_TAG} 已存在，跳过${NC}"
        exit 1
    fi

    CURRENT_COMMIT=$(git rev-parse --short HEAD)

    # 打 tag
    git tag -a "$NEW_TAG" -m "Snapshot: ${MSG}" && git push origin "$NEW_TAG" 2>/dev/null || true

    echo ""
    echo -e "${GREEN}✓ 版本 ${NEW_TAG} 存档成功！${NC}"
    echo "  Commit: ${CURRENT_COMMIT}"
    echo "  说明: ${MSG}"
    echo ""
    echo -e "${YELLOW}提示: 请手动更新 CHANGELOG.md 中的变更详情${NC}"
    echo ""

    exit 0
fi

# --- 命令: rollback ---
if [ "$1" = "rollback" ] || [ "$1" = "restore" ] || [ "$1" = "back" ]; then
    echo -e "${BLUE}可用回退版本：${NC}"
    echo ""

    TAGS=($(git tag -l 'v*' --sort=-v:refname 2>/dev/null))
    if [ ${#TAGS[@]} -eq 0 ]; then
        echo -e "${RED}没有可回退的版本存档${NC}"
        exit 1
    fi

    for i in "${!TAGS[@]}"; do
        tag="${TAGS[$i]}"
        COMMIT=$(git log -1 --format='%h %s' "$tag")
        echo "  [$((i+1))] ${tag}  — ${COMMIT}"
    done
    echo ""
    echo -e "  [0] 取消"
    echo ""
    read -p "$(echo -e ${CYAN}输入序号回退: ${NC})" choice

    if [ -z "$choice" ] || [ "$choice" = "0" ]; then
        echo "取消操作"; exit 0
    fi

    INDEX=$((choice - 1))
    if [ $INDEX -lt 0 ] || [ $INDEX -ge ${#TAGS[@]} ]; then
        echo -e "${RED}无效序号${NC}"; exit 1
    fi

    SELECTED="${TAGS[$INDEX]}"
    echo ""
    echo -e "${YELLOW}正在回退到 ${SELECTED}...${NC}"
    git checkout "$SELECTED"
    echo ""
    echo -e "${GREEN}✓ 已切换到 ${SELECTED}${NC}"
    echo -e "  使用 ${CYAN}./snapshot.sh latest${NC} 可回到最新版本"
    echo ""
    exit 0
fi

# --- 命令: latest ---
if [ "$1" = "latest" ] || [ "$1" = "main" ]; then
    echo -e "${YELLOW}正在切回到最新版本 (main)...${NC}"
    git checkout main
    echo -e "${GREEN}✓ 已回到最新版本${NC}"
    echo "  最新 commit: $(git log -1 --oneline)"
    echo ""
    exit 0
fi

# --- 未知命令 ---
echo -e "${RED}未知命令: $1${NC}"
echo ""
echo "用法:"
echo "  ./snapshot.sh              查看所有版本"
echo "  ./snapshot.sh save \"说明\"  创建新存档"
echo "  ./snapshot.sh rollback     选择版本回退"
echo "  ./snapshot.sh latest       回到最新版"
exit 1
