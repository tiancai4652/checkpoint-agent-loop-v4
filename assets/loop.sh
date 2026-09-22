#!/usr/bin/env bash
# 三角色驱动 v4 · 无人值守循环
# 用法: ./loop.sh <session_id> [超时分钟]   （session_id 用 `opencode session list` 查）
# 依赖: opencode（需登录可用模型）+ taskdeck（本脚本自己也是后台长任务）
# 说明: 脚本只认根路径 PRD.md——它是根指针，指向当前轮 docs/runs/NNN-<功能名>/PRD.md，
#       开新轮时驾驶者会刷新指针，本脚本无需改动。
# 启动方式：不要裸跑，用 task-run 派发，让面板监控本循环：
#   python3 ~/tools/taskdeck/task-run.py \
#     --name "三角色v4无人值守循环" \
#     --goal "反复推进本轮 PRD.md 当前任务，到检查点等评审或按推荐方案继续" \
#     --max-minutes 480 \
#     -- bash ./loop.sh <session_id> [超时分钟]
SID="${1:?usage: loop.sh <session_id> [超时分钟]}"
TIMEOUT_MIN="${2:-10}"

while true; do
  echo "=== $(date) driver cycle ==="
  OUT=$(opencode run --session "$SID" --continue --agent engineer \
        "继续执行 PRD.md 当前任务，到达里程碑输出 [[CHECKPOINT]]" --format json 2>&1)
  if echo "$OUT" | grep -q '\[\[CHECKPOINT\]\]'; then
    echo "到达检查点，等你评审（${TIMEOUT_MIN} 分钟内未回复则按推荐方案继续）"
    # read 超时：期间用户回车 = 有批复，停下等指示；超时 = 按推荐方案默认继续
    if read -t $((TIMEOUT_MIN * 60)) -p "用户回复后回车继续；${TIMEOUT_MIN} 分钟超时..." _ </dev/tty 2>/dev/null; then
      echo "收到用户批复，等用户指示后继续"; break
    fi
    echo "超时 ${TIMEOUT_MIN} 分钟，按推荐方案默认继续"
    continue
  fi
  if echo "$OUT" | grep -q '\[\[NEEDS-USER\]\]'; then
    echo "需要用户决策，停下"; break
  fi
  sleep 20
done
