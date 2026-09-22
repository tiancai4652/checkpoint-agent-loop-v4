# 三角色驱动 v4（checkpoint-agent-loop-v4）

一个 [opencode](https://opencode.ai) skill：**说一句话，AI 团队自动把想法落地，你只在关键节点出现。**

「三角色」= 产品经理（pm）+ 实现工程师（engineer）+ 技术研究员（researcher）。PM 跟你把需求聊清楚，工程师一点一点实现，撞到技术墙自动派研究员摸索；只有到达**检查点**才停下来等你评审。

v4 = **v3 全量能力 + 设计链路（自动分级）+ PM 增强**：

```
你的想法 → 开轮(建 docs/runs/NNN-<功能名>/) → pm(聊清楚 + RedTeam 批需求) → engineer(动手实现) → researcher(撞墙时探索)
              │                                    │                              │
              │                                    └─ PM Skills 18件套按需辅助      └─ 前端任务自动判 L1/L2：
              ├─ v2-1 大白话汇报：所有进展当小白讲，术语配人话                       L1 组件小改：ui-ux-pro-max 检索 → 确认 → 写码
              ├─ v2-2 TaskDeck：后台长任务上监控面板，自动判卡死/空转/超期            L2 新页面/大改：ui-ux-pro-max 定视觉 → Webdesign 出规范
              ├─ v3-4 轮次归档：每轮独立目录，做完即档案，新旧轮次永不混淆                            → 你拍板 → 实现
              └─ v4-5/6 设计链路 + PM 增强                                          L2 大改/落地页/仪表盘/你说"想先看样子"：加跑 huashu 高保真
```

## v4 新增一：设计链路（自动分级）

前端任务不再只查一次风格，而是**按任务分量走不同深度的链路**——判级由 engineer 自动完成，判完一句话告诉你，PRD 里写默认级别，你随时可改：

| 级别 | 什么任务 | 链路 |
|---|---|---|
| **L1 组件级小改** | 改样式 / 换文案 / 调布局 / 单组件 | `ui-ux-pro-max` 检索 → 2~3 个口语化候选 → 你确认 → 实现 |
| **L2 新页面/大改** | 新页面 / 落地页 / 仪表盘 / 整站视觉 | `ui-ux-pro-max` 定视觉 → `Webdesign` 出设计规范 → 你拍板 → 实现 |
| **L2 加重**（按需） | 大改 / 落地页 / 仪表盘，或你说"想先看到样子" | 上面基础上加跑 `huashu-design` 出 2~3 方向 **HTML 高保真原型**，先看到真实样子再拍板 |

为什么分级：设计环节的本质是**降低你拍板时的信息差**——信息差成本应该和页面重要性成正比。落地页赌错方向返工大，值得画高保真；改个表单样式不值得。

## v4 新增二：PM 增强

- **PM Skills 按需辅助**：pm 讨论需求时按类型挑最贴合的 1~2 件（PRD / 用户旅程图 / JTBD / 故事板 / 原型人物画像…），不逐件套用，小需求不调。
- **定稿前轻量 RedTeam 批判**：PRD 提交你确认**之前**，pm 先调 `RedTeam` 产出「**3 个最强反驳 + 推荐**」，连 PRD 一起给你——你看完反驳再拍板，防"确认了伪需求"。明确的小改动跳过；RedTeam 缺失则降级为 pm 自查三问。

## 继承 v3 / v2 的能力

- **轮次归档（v3）**：每轮任务独立目录 `docs/runs/NNN-<功能名>/`，项目根的 `PRD.md`/`CHECKPOINT-REPORT.md` 是指向当前轮的 symlink 指针——做完即档案，**没有"事后整理"这个动作**，多轮功能开发永不混淆
- **大白话汇报（v2）**：检查点评审、需要拍板处、进度说明，默认读者是不懂编程的人；汇报固定四段：这段干了啥 → 现在到哪了 → 有没有坏消息 → 你只需要决定什么
- **TaskDeck 集成（v2）**：超 1 分钟的后台任务必须用 `task-run` 派发，面板（http://127.0.0.1:8747/）自动判定运行中/卡死/空转/超期
- **检查点门控**：`[[CHECKPOINT]]` / `[[NEED-RESEARCH]]` / `[[NEEDS-USER]]` 签名决定停/走
- **评审必含方案分析**：问题 → 2~3 候选方案（带推荐+理由）→ 总体倾向
- **超时默认**：检查点等你 10 分钟没回 → 按推荐方案继续，`DECISIONS.md` 留痕
- **初始化确认关卡**：PRD 没确认前禁止写任何文件
- **探索回填 + 知识沉淀**：研究结论落盘 `docs/research/` 并登记本轮 PRD；检查点强制走"有无新知识"，跨轮知识归档进 `docs/decisions-archive/`

## 安装

```bash
# 克隆到 opencode 全局 skill 目录
git clone https://github.com/tiancai4652/checkpoint-agent-loop-v4.git \
  ~/.config/opencode/skills/checkpoint-agent-loop-v4
```

然后**重启 opencode**（skill 启动时加载，不热更新）。

### 依赖（全部可选，缺失自动降级，无硬依赖）

设计链路 / PM 增强用到的 skill **不用预装**：首次用到时 agent 会探活，缺失就从上游自装，装不了就降级继续（当轮降级、重启后生效）。

| skill | 来源 | 谁用 | 缺失时 |
|---|---|---|---|
| ui-ux-pro-max | [nextlevelbuilder/ui-ux-pro-max-skill](https://github.com/nextlevelbuilder/ui-ux-pro-max-skill)（MIT） | engineer | 用常识给口语化风格候选 |
| Webdesign | [danielmiessler/LifeOS](https://github.com/danielmiessler/LifeOS) → `LifeOS/install/skills/Webdesign/`（**只拷这一个文件夹，不装整个 LifeOS**） | engineer | engineer 自行按方向写 |
| huashu-design | [alchaincyf/huashu-design](https://github.com/alchaincyf/huashu-design)（自装剔除 26MB BGM/demos） | engineer（按需） | 跳过高保真，用文字方案 |
| RedTeam | [danielmiessler/LifeOS](https://github.com/danielmiessler/LifeOS) → `LifeOS/install/skills/RedTeam/` | pm | pm 自查三问 |
| PM Skills | [deanpeters/Product-Manager-Skills](https://github.com/deanpeters/Product-Manager-Skills) | pm | pm 裸聊，不阻塞 |
| agent-project-bootstrapper | 建议先跑，建 AGENTS/DECISIONS/CHECKPOINT-REPORT 三件套底座 | 驾驶者 | 建议先跑再开车 |
| taskdeck | 后台长任务监控面板 | engineer | 后台任务退化为普通执行，无健康监控 |

## 用法

对项目说：

> **三角色驱动v4，把〇〇落地。**

触发词：`三角色驱动v4` / `三角色v4` / `三角色驱动4.0`

流程：

1. **建底座**：先跑 `agent-project-bootstrapper` 生成三件套，确认不变项
2. **建角色**：把 `assets/pm.md`、`assets/engineer.md`、`assets/researcher.md` 复制到项目的 `.opencode/agent/`（必须放这里才会被识别为 subagent）
3. **开轮 + 写契约**：skill 自动建 `docs/runs/NNN-<功能名>/` 并刷新根指针；PM 按需调 PM Skills 跟你聊清楚，定稿前跑轻量 RedTeam 批判，你说「确认」才开写
4. **开车**：AI 按驾驶规则自动推进；前端任务自动判 L1/L2 走设计链路；后台长任务上 TaskDeck 面板
5. **到检查点**：大白话汇报 + 方案分析，等你评审（10 分钟没回按推荐继续，你说错了可随时打回）
6. **换功能再来一轮**：再次触发即可，新轮新目录，历史自动归档

### 无人值守（可选）

用 task-run 派发循环脚本，它自己也会被面板监控（脚本只认根指针，开新轮无需改动）：

```bash
python3 ~/tools/taskdeck/task-run.py \
  --name "三角色v4无人值守循环" \
  --goal "反复推进本轮 PRD.md 当前任务，到检查点等评审或按推荐方案继续" \
  --max-minutes 480 \
  -- bash ~/.config/opencode/skills/checkpoint-agent-loop-v4/assets/loop.sh <session_id> [超时分钟]
```

## 相关版本

- [checkpoint-agent-loop](https://github.com/) 原版：三角色 + 检查点门控
- [checkpoint-agent-loop-v2](https://github.com/tiancai4652/checkpoint-agent-loop-v2)：+ 大白话汇报 / TaskDeck / 前端设计关卡
- [checkpoint-agent-loop-v3](https://github.com/tiancai4652/checkpoint-agent-loop-v3)：+ 轮次归档
- **checkpoint-agent-loop-v4（本仓库）**：+ 设计链路（分级）+ PM 增强（PM Skills + RedTeam）

## 文件结构

```
checkpoint-agent-loop-v4/
├── README.md            ← 本文件
├── SKILL.md             ← skill 主文件（触发词 + 规则总纲）
└── assets/
    ├── DRIVER.md        ← 驾驶规则：开轮 / 主循环 / 需求批判门控 / 设计链路（分级+依赖矩阵）/ TaskDeck / 超时默认
    ├── pm.md            ← 产品经理角色（聊需求、PM Skills 按需、定稿前 RedTeam 批判、写 PRD）
    ├── engineer.md      ← 工程师角色（实现、门控签名、task-run、L1/L2 设计链路）
    ├── researcher.md    ← 研究员角色（调研、结论回填）
    ├── PRD.md.tmpl      ← 需求契约模板（所属轮次 + 设计级别 + 需求批判 + 研究清单）
    └── loop.sh          ← 无人值守循环脚本（只认根指针）
```

## 成本提示

- engineer 用强编码模型，pm/researcher 用便宜模型——长程跑下来差很多
- 设计链路能 L1 不 L2，L2 里能不加 huashu 就不加（huashu 生成高保真原型最重）
- 无人值守会持续烧 token，面板上看到空转/反复失败及时 kill

## License

MIT
