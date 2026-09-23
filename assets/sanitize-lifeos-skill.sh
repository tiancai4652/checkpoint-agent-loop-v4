#!/usr/bin/env bash
# LifeOS 系 skill 跨环境适配：装到非 LifeOS 环境（如 opencode）后运行一次。
# 做两件事：
#   1) 剥离「强制语音通知」块（原会 POST localhost:31337，无此服务会空跑/报错）
#   2) 中和 LifeOS 专属日志路径（~/.claude/LIFEOS/MEMORY/... → /dev/null）
# 用法: ./sanitize-lifeos-skill.sh <已安装的 skill 目录>
# 例:   ./sanitize-lifeos-skill.sh ~/.config/opencode/skills/RedTeam
set -e
DIR="${1:?用法: sanitize-lifeos-skill.sh <已安装的 skill 目录>}"
[ -d "$DIR" ] || { echo "目录不存在: $DIR" >&2; exit 1; }
python3 - "$DIR" <<'PY'
import re, sys, pathlib
root = pathlib.Path(sys.argv[1])
NOTE = ("## Voice Notification（已适配当前环境：跳过）\n\n"
        "本 skill 原通过 LifeOS 语音服务（`localhost:31337`）播报；当前环境无此服务 "
        "→ **跳过语音通知，直接执行工作流**。\n")
VOICE_PATS = [
    r"## 🚨 MANDATORY: Voice Notification.*?\*\*This is not optional\..*?\*\*\n",
    r"## Voice Notification\n\n```bash\ncurl -s -X POST http://localhost:31337/notify.*?```\n",
]
changed = 0
for p in root.rglob("*.md"):
    t = p.read_text(encoding="utf-8"); orig = t
    for pat in VOICE_PATS:
        t = re.sub(pat, NOTE, t, flags=re.S)
    t = t.replace("~/.claude/LIFEOS/MEMORY/SKILLS/execution.jsonl", "/dev/null")
    if t != orig:
        p.write_text(t, encoding="utf-8"); changed += 1
print(f"sanitize 完成：{changed} 个文件已适配（{root}）")
PY
