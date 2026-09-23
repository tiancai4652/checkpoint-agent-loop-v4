---
name: checkpoint-agent-loop-v4
description: |
  三角色驱动 v4 —— checkpoint-agent-loop-v3 的设计链路增强版。"一句想法 → 全自动落地"：PM 角色跟你讨论清楚需求，工程师角色一点一点实现，撞墙自动派研究员；到检查点停下等你评审。v4 继承 v3 全部能力（大白话汇报 / TaskDeck / 轮次归档），并新增：
  (5) 设计链路（自动分级）：前端任务按 L1/L2 判级——L1 组件小改走 ui-ux-pro-max 检索 + 口语化确认；L2 新页面/大改走 ui-ux-pro-max 定视觉 → Webdesign 出设计规范 → 你拍板 → 实现；大改/落地页/仪表盘或你说"想先看样子"时，加跑 huashu-design 出三方向高保真原型再拍板。
  (6) PM 增强：需求讨论阶段 pm 按需调用 PM Skills 18 件套（PRD/旅程图/JTBD/故事板…）；PRD 定稿前跑轻量 RedTeam 出「3 个最强反驳 + 推荐」连 PRD 一起给你——防"确认了伪需求"；L2 大改时 RedTeam 也对设计方案批一轮。

  Use when the user says: 三角色驱动v4 / 三角色v4 / 三角色驱动4.0 / 按 v4 三角色做。
  NOT FOR：只立规矩不搭团队（用 agent-project-bootstrapper）；要原版无改造行为（用 checkpoint-agent-loop）；要 v2/v3 行为（用 checkpoint-agent-loop-v2 / -v3）。
---

# 三角色驱动 v4（v3 全量 + 设计链路 + PM 增强）

## 如何触发（与应用边界）

**触发本 skill 的话术**（命中即加载本 skill）：
> 「**三角色驱动v4，把〇〇落地。**」/「**按三角色v4做**」/「**三角色v4，先派PM跟我讨论**」

命中词：`三角色驱动v4` / `三角色v4` / `三角色驱动4.0`。

**与近亲 skill 的分水岭**：
- 说「按检查点驱动 / 三件套启动」→ **agent-project-bootstrapper**（立规矩 = 宪法）
- 说「三角色 / 检查点 loop」（无 v2/v3/v4）→ **checkpoint-agent-loop** 原版
- 说「三角色驱动v2」→ **checkpoint-agent-loop-v2**（原版 + 大白话 + TaskDeck + 前端设计关卡）
- 说「三角色驱动v3」→ **checkpoint-agent-loop-v3**（v2 全量 + 轮次归档）
- 说「三角色驱动v4」→ **本 skill**（v3 全量 + 设计链路分级 + PM 增强：PM Skills + RedTeam 需求批判）
- 说「按检查点驱动＋三角色v4，把〇〇落地」→ bootstrapper + 本 skill 都触发（推荐：先立规矩、再落地）

若项目还没有三件套（AGENTS/DECISIONS/CHECKPOINT-REPORT），先补跑 bootstrapper。

## 核心

继承原版机制：**三角色分工 + 检查点门控 + 探索回填 + 知识沉淀**。v2 加「用户体验层」，v3 加「归档层」，v4 加「设计链路层 + 需求批判层」：

```
想法 → 开轮(建 docs/runs/NNN-<功能名>/) → pm(讨论清楚 + RedTeam 批需求) → engineer(落地) → researcher(撞墙探索)
         │                                    │                              │
         │                                    └─ PM Skills 18件套按需辅助      └─ 前端任务按级走设计链路：
         ├─ v2-1 大白话：所有汇报当小白讲，术语配人话                            L1 组件小改：ui-ux-pro-max 检索 → 口语化确认 → 写码
         ├─ v2-2 TaskDeck：后台长任务 task-run 派发，面板看健康                   L2 新页面/大改：ui-ux-pro-max 定视觉 → Webdesign 出规范
         ├─ v3-4 轮次归档：每轮独立目录，根目录指针，做完即归档                                    → 你拍板 → 实现
         └─ v4-5/6 设计链路 + PM 增强                                            L2 大改/落地页/仪表盘/你说"想先看样子"：加跑 huashu 高保真
```

### v4 增量详解

继承 v2/v3 全部增量（大白话汇报 / TaskDeck / 轮次归档，规则见 `assets/DRIVER.md`），外加：

5. **设计链路（v4 硬性，自动分级）**：涉及前端/UI 的任务，engineer 自动判级（判完一句话告知用户，PRD 写默认级别，用户可随时改判）：
   - **L1 组件级小改**（改样式/换文案/调布局/单组件）：`ui-ux-pro-max` 检索 → 口语化候选给用户确认 → 实现。
   - **L2 新页面/大改**（新页面、落地页、仪表盘、整站视觉）：`ui-ux-pro-max` 定视觉 → `Webdesign` 出设计规范 → `[[NEEDS-USER]]` 拍板 → 实现；L2 大改时 `RedTeam` 对设计方案批一轮（可选）。
   - **加重触发（L2 内按需）**：大改/落地页/仪表盘，或用户说"想先看到样子"→ 加跑 `huashu-design` 出 2~3 方向 HTML 高保真原型，再拍板。
   - 设计链路涉及的 skill（`ui-ux-pro-max` / `Webdesign` / `huashu-design` / `RedTeam`）全部「探活 → 缺则自装 → 装不了降级」，无硬依赖，缺谁降谁（来源见 DRIVER 依赖矩阵）。
6. **PM 增强（v4 硬性）**：
   - **PM Skills 按需辅助**：pm 讨论需求时按需求类型调用 PM Skills（PRD/用户旅程图/JTBD/故事板/原型人物画像等），选最贴合的 1~2 件，不逐件套用；缺失则 pm 裸聊，不阻塞。
   - **定稿前轻量 RedTeam 批判**：PRD 提交用户确认**之前**，pm 调 RedTeam（轻量单轮）产出「3 个最强反驳 + 推荐」，连 PRD 一起给用户——用户看完反驳再拍板。明确的小改动/指令式任务跳过；RedTeam 缺失降级为 pm 自查三问（伪需求？更简解法？用户真要的是什么？）。

## 使用流程

> 下文 `assets/...` 均指**本 skill 安装目录**下的文件（如 `~/.config/opencode/skills/checkpoint-agent-loop-v4/assets/`），不是项目里的目录。

1. **建底座**：先跑 `agent-project-bootstrapper` 生成三件套，确认不变项。
2. **建角色**：把 `assets/` 下三个 role 文件（`pm.md`/`engineer.md`/`researcher.md`）放到项目的 `.opencode/agent/`，或合并进单个驾驶者 prompt。
3. **开轮 + 写契约**：每次触发都先「开轮」（建 `docs/runs/NNN-<功能名>/`，刷新根目录 `PRD.md`/`CHECKPOINT-REPORT.md` 指针，规则见 `assets/DRIVER.md`「开轮」）；再复制 `assets/PRD.md.tmpl` 到本轮目录为 `PRD.md`，pm 跟用户讨论填充（按需调 PM Skills；**定稿前跑轻量 RedTeam 批判**），**直到用户确认**。
4. **开车**：按 `assets/DRIVER.md` 执行主循环（读三件套+本轮PRD → 判门控 → 派 engineer（前端任务自动判 L1/L2 走设计链路）→ 撞墙派 researcher → 后台任务走 TaskDeck → 到检查点用大白话停下）。
5. **无人值守**（可选）：用 task-run 派发 `assets/loop.sh <session_id> [超时分钟]`（本身就是后台长任务，进面板被监控）。

## 关键规则

- **初始化确认关卡（硬性）**：用户没明确说「确认/OK/开始」，禁止写文件、改代码、开实现。
- **先开轮再开车（v3 硬性）**：每次触发本 skill，先建/确认本轮 `docs/runs/NNN-<功能名>/` 目录并刷新根指针，再进入 pm 讨论；所有轮次产出写本轮目录，不落根目录。
- **大白话汇报（v2 硬性）**：所有面向用户的汇报走 DRIVER 的「大白话汇报」模板。
- **评审必含方案分析（硬性）**：停到 `[[CHECKPOINT]]`/`[[NEEDS-USER]]` 必须给「问题 → 2~3 候选（带推荐+理由）→ 总体倾向」，且每个方案用大白话讲后果。用户问"你觉得怎么样"直接按此结构作答，不反问。
- **超时默认（10 分钟）**：检查点用户 10 分钟未回复 → 按推荐方案继续，`DECISIONS.md` 留痕。初始化确认关卡不适用。
- **后台长任务（TaskDeck 可用则用）**：超 1 分钟的后台任务先探活 `127.0.0.1:8747`；可用 → `task-run` 派发并把详情页 URL 给用户；**不可用 → 先自装 TaskDeck（见下 Gotchas）**，装不了才回退 `nohup` + 日志文件并告知用户日志路径——不得卡住或静默裸跑。详见 DRIVER「后台长任务」。
- **前端按级走设计链路（v4 硬性）**：engineer 自动判 L1/L2，判完一句话告知用户、PRD 写默认级别；L1 轻量路径，L2 全链路（大改/落地页/仪表盘/用户要求时加跑 huashu 高保真）。依赖 skill 缺失时先自装、装不了降级（详见 DRIVER「设计链路」）。用户已确认设计基线的除外。
- **PRD 定稿前过 RedTeam 批判（v4 硬性）**：pm 提交 PRD 给用户确认前，先出「3 个最强反驳 + 推荐」（轻量单轮）；小任务跳过，RedTeam 缺失降级为自查三问。
- **门控签名**：`[[CHECKPOINT]]` / `[[NEED-RESEARCH]]` / `[[NEEDS-USER]]`，方括号签名唯一，grep 判停/走。
- **探索回填 + 学习沉淀**：研究员结论落盘 `docs/research/<topic>.md` 并登记本轮 PRD；每个检查点强制走"有无新知识"判断，有则写 `docs/decisions-archive/<主题>.md`（跨轮共享的知识，不进轮次目录）。
- **决策带轮次标记**：写 `DECISIONS.md` 的每条决策开头带 `[NNN-<功能名>]`，多轮日志可检索。
- **成本**：engineer 用强编码模型，pm/researcher 用便宜模型；设计链路能 L1 不 L2，L2 里能不加 huashu 就不加。

## 角色权限（写进 subagent 定义时用）

| 角色 | 权限 | 定位 |
|---|---|---|
| pm | read/edit/write/grep/glob/skill | 只读调研 + 产出契约（按需调 PM Skills、定稿前轻量 RedTeam），写动作发生在用户确认后 |
| engineer | bash/edit/write/grep/glob/webfetch/task/todowrite/skill | 实现主体；长任务 task-run 派发；前端按 L1/L2 走设计链路 |
| researcher | webfetch/grep/glob/read | 只调研不写业务代码，产出结论 + 可搬片段 |

注意：pm 需 `skill` 权限才能调 PM Skills / RedTeam；engineer 需 `skill` 权限才能调设计链路 skill；缺失时各自降级，不阻塞。

## Gotchas

- **角色文件放 `.opencode/agent/` 才被 opencode 识别**为 subagent；放其他目录只是普通 markdown。
- **模型很关键**：pm/researcher 误用强编码模型会让长程成本失控。
- **门控签名要唯一**：`[[CHECKPOINT]]` 方括号包围，避免与正文普通提及混淆。
- **TaskDeck（后台服务，可用则用，缺可自装）**：派发前 `curl -s -m 2 http://127.0.0.1:8747/api/health` 探活；**没装 → 自装**（`git clone --depth 1 https://github.com/tiancai4652/taskdeck /tmp/taskdeck && bash /tmp/taskdeck/install.sh`，Python3 stdlib 零依赖、跨平台、默认注册开机自启）；自装失败（无网络等）→ 回退 `nohup` + 本轮目录日志（见 DRIVER「后台长任务」），不阻塞。
- **根指针（symlink 或指针壳）**：`PRD.md` / `CHECKPOINT-REPORT.md` 是指向本轮目录文件的入口。mac/Linux 用 `ln -sfn`（读取透明）；**Windows/无权限 → 用指针壳文件**（根文件首行 `POINTER: docs/runs/NNN-<功能名>/PRD.md`），读取方按该行解析。真实文件始终写在本轮目录。
- **存量项目迁移**：第一次对老项目开轮时，把根目录已有的 `PRD.md`/`CHECKPOINT-REPORT.md` 挪进 `docs/runs/001-<功能名>/` 再建指针，不要覆盖丢历史。
- **设计链路 / PM skill 来源**（全部探活多根 → 缺则自装 → 装不了降级，完整命令见 DRIVER 依赖矩阵）：
  - 探活**多根**：`~/.config/opencode/skills` → `~/.opencode/skills` → `~/.claude/skills`（只查一个根会误判缺失、重复自装）
  - `ui-ux-pro-max`：`github.com/nextlevelbuilder/ui-ux-pro-max-skill`（MIT）
  - `huashu-design`：`github.com/alchaincyf/huashu-design`（自装**只删 `assets/bgm-*.mp3`**，保留 jsx/svg 组件与 demos）
  - `Webdesign` / `RedTeam`：`github.com/danielmiessler/LifeOS` → `LifeOS/install/skills/<名字>/`（**只拷该文件夹，不装整个 LifeOS**）；装后跑本 skill 目录下的 `assets/sanitize-lifeos-skill.sh <目录>` 剥语音通知、中和 LifeOS 日志路径
  - `PM Skills`：`github.com/deanpeters/Product-Manager-Skills` → 仓库 `skills/` 下 77 个 skill，`cp -R skills/* <skills根>/`
  - 旧 `design` skill（claudekit，无公开源）已被 Webdesign 替代，不再引用
  - 新装的 skill 本会话可能加载不到（opencode 启动时载入 skill 列表），当轮走降级、重启后生效
- **本 skill 面向 opencode**：角色文件放 `.opencode/agent/`、无人值守用 `opencode run --session`、skill 根按上面多根探活；在 claude/codex 上需改角色目录与 loop 命令。
- **无人值守会烧 token**：`loop.sh` 只处理门控签名，engineer 撞墙必须输出 `[[NEED-RESEARCH]]`，不得硬扛空转。
- **新增/修改 skill 后需重启 opencode** 才会被加载。

## 资源

- 角色模板：`assets/pm.md`、`assets/engineer.md`、`assets/researcher.md`
- 驾驶规则：`assets/DRIVER.md`
- 需求契约模板：`assets/PRD.md.tmpl`
- 无人值守：`assets/loop.sh`
- LifeOS skill 跨环境适配：`assets/sanitize-lifeos-skill.sh`（位于本 skill 目录；装后剥语音通知 + 中和 LifeOS 路径）
- 配套监控：taskdeck skill（`~/.config/opencode/skills/taskdeck/`，可选；没装则后台任务回退到日志）
