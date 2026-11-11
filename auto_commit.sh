#!/usr/bin/env bash
# auto_commit.sh —— 检测代码变动后自动提交并推送到 GitHub
#
# 用法:
#   ./auto_commit.sh              # 持续监控（默认每 30 秒检查一次）
#   ./auto_commit.sh once         # 只检查一次（可配合 cron 使用）
#   INTERVAL=60 ./auto_commit.sh  # 自定义检查间隔（秒）
#
# 日志: .git/auto_commit.log

set -u
cd "$(dirname "$0")" || exit 1

INTERVAL="${INTERVAL:-30}"
LOG_FILE=".git/auto_commit.log"

log() { echo "[$(date '+%F %T')] $*" | tee -a "$LOG_FILE"; }

commit_changes() {
    git add -A
    git diff --cached --quiet && return 1  # 只是 gitignore 之类的空变化

    local count files msg
    count=$(git diff --cached --name-only | wc -l)
    files=$(git diff --cached --name-only | head -5 | tr '\n' ' ')
    msg="自动提交: ${count} 个文件变更 (${files})$(date '+%F %T')"

    if git commit -m "$msg" >/dev/null 2>&1; then
        log "已提交: $msg"
        return 0
    fi
    log "提交失败"
    return 1
}

push_if_needed() {
    local ahead
    ahead=$(git rev-list --count "@{upstream}..HEAD" 2>/dev/null || echo 0)
    if [ "$ahead" -gt 0 ]; then
        if git push >/dev/null 2>&1; then
            log "已推送 ${ahead} 个提交到 origin"
        else
            log "推送失败（网络问题），下次检查时自动重试"
        fi
    fi
}

check_once() {
    # Git 操作进行中（如编辑器执行 rebase/merge）时跳过，避免冲突
    if [ -f .git/index.lock ] || [ -d .git/rebase-merge ] || [ -f .git/MERGE_HEAD ]; then
        log "Git 操作进行中，跳过本次检查"
        return
    fi

    if [ -n "$(git status --porcelain)" ]; then
        commit_changes && push_if_needed
    else
        push_if_needed  # 补推之前因断网未推送成功的提交
    fi
}

if [ "${1:-}" = "once" ]; then
    check_once
    exit 0
fi

log "开始监控 ${PWD}（每 ${INTERVAL} 秒检查一次，Ctrl+C 停止）"
while true; do
    check_once
    sleep "$INTERVAL"
done
