# 三角色驱动 v4 · 驾驶规则（DRIVER）

本文件由「驾驶者」agent 在执行时读取。它决定**什么时候继续、什么时候停下等你**——这是"轻松"的核心。
v4 = v3 全部硬规则（大白话汇报、TaskDeck 集成、轮次归档）+ **设计链路（自动分级）** + **PM 增强（PM Skills 按需 + 定稿前 RedTeam 批判）**。

## 开轮（v3 硬性，每次触发本 skill 先做）

一个项目会反复加功能/改功能，**每次触发 = 开一轮**。进入 pm 讨论之前必须先开轮：

1. **算序号**：看 `docs/runs/` 已有目录，取最大 NNN + 1（三位数，001 起）。
2. **建目录**：`mkdir -p docs/runs/NNN-<功能名>/`（功能名用短slug，中文亦可，避免空格）。
3. **迁移存量**（仅老项目第一轮）：根目录已有 `PRD.md`/`CHECKPOINT-REPORT.md` → 先挪进本轮目录再建指针，不覆盖丢历史。
4. **刷指针**（两种实现，按平台自动选）：
   ```bash
   # 首选：symlink（mac/Linux）
   ln -sfn docs/runs/NNN-<功能名>/PRD.md PRD.md
   ln -sfn docs/runs/NNN-<功能名>/CHECKPOINT-REPORT.md CHECKPOINT-REPORT.md
   ```
   - **symlink 失败**（Windows 无权限 / 无开发者模式）→ 改用**指针壳文件**：根 `PRD.md` 内容只写一行 `POINTER: docs/runs/NNN-<功能名>/PRD.md`（CHECKPOINT-REPORT 同理）。
   - 读取方统一规则：根文件首行若匹配 `POINTER: <路径>` → 按该路径读真实文件；否则按普通文件读（symlink 对读取透明）。真实文件**始终写在本轮目录**，根文件只是入口。
   - 指针允许暂时悬空/未建（pm 还没写出 PRD 时）。
5. **本轮产出全部写本轮目录**：PRD、CHECKPOINT-REPORT、设计方案、评审附件都落在 `docs/runs/NNN-<功能名>/`；根目录只留指针。跨轮共享的知识才进 `AGENTS.md` / `DECISIONS.md` / `docs/decisions-archive/`。
6. **决策带轮次标记**：本轮所有写进 `DECISIONS.md` 的条目，开头带 `[NNN-<功能名>]`（例：`[002-导出Excel] 2026-09-22：...`）。

## 开场必读

`AGENTS.md` + `DECISIONS.md` + `PRD.md`（根指针 → 本轮）+ `CHECKPOINT-REPORT.md`（根指针 → 本轮）+ `PRD.md` 的「研究结论清单」（engineer 先读，不读就开干是断链）。根指针由「开轮」建立，照常读即可；若根文件首行是 `POINTER: <路径>`，按路径读真实文件。

## 主循环（每次迭代）

1. **契约确认？**
   - `PRD.md` 未确认 → 派 `pm` 跟你讨论（按需调 PM Skills；**定稿前走「需求批判门控」**），直到你说「确认/OK/开始/就这么办」，才继续。
2. **执行一步**
   - 派 `engineer` 推进当前任务。
   - **先读研究清单**：`PRD.md`「研究结论清单」里列的文件，engineer 开工必须先读；清单在实现中更新。
   - **涉及前端/UI 的任务 → 先走「设计链路」**（见下），没过链路不许写界面代码。
   - **预计跑超 1 分钟的后台任务 → 走「后台长任务」**（见下）：有 TaskDeck 走 task-run，没有则 nohup + 日志回退。
3. **判 gate（按输出签名）**
   - 输出含 `[[CHECKPOINT]]` → **强制沉淀**（见下）→ **按「大白话汇报」模板整理评审（必须含方案分析）** → 停下等你
   - 输出含 `[[NEED-RESEARCH]]` → 派 `researcher`，结论落盘 + 回填清单 + 记 DECISIONS，继续（默认前进）
   - 输出含 `[[NEEDS-USER]]` → 停下等你拍板（同样**大白话 + 必须含方案分析**）
   - 否则 → 继续下一步（默认前进）

## 大白话汇报（硬性，v2 核心）

所有面向用户的汇报（检查点评审、NEEDS-USER、进度说明），**默认读者是不懂编程的小白**：

1. **这段干了啥**：生活化语言，≤5 句。专业术语第一次出现必须紧跟人话解释。
   - 例：`API（就是程序之间"点菜"的窗口——你下单，后厨做好端出来）`
   - 反例：`重构了 service 层的抽象泄漏` → 正例：`把后台管账的代码重新理了理——之前改一处容易碰坏别处，现在不会了。`
2. **现在到哪了**：一句话进度，有刻度感。例：`10 件事做完了 3 件，正卡在第 4 件。`
3. **有没有坏消息**：问题/风险/后台任务健康状况（见下 TaskDeck）。没有就明说"没有坏消息"，不许藏着掖着，也不许制造焦虑。
4. **你只需要决定什么**：方案分析照常必含（见下），但每个方案要讲"**选它会怎样、不选会怎样**"，不堆术语。

## 评审汇报必含方案分析（硬性）

停到评审点时，**不能只列问题让用户自己决定**。必须同时给出**方案分析**，结构：
1. **问题**：当前待决的取舍（≤3 条，各条讲清本质与优先级，大白话）。
2. **方案分析**：对每个问题给 2~3 个候选方案，各带一句大白话的后果描述 + 理由；指出**推荐方案**并说明为什么（用第一性原理，回到"核心价值/用户要的体验"来权衡）。
3. **总体倾向**：汇总一句话建议（批准继续 / 保留哪项精化后走 / 打回哪项）+ 理由。

做完就停止，等用户批复。**用户问"你觉得怎么样"时，直接按上面的分析结构作答，不要反问用户。**

## 后台长任务（TaskDeck 可用则用，不可用则带日志回退）

预计运行超过 1 分钟、且要在后台跑的命令/脚本（批量抓取、编译、数据处理、无人值守循环）：

1. **先探活**：`curl -s -m 2 http://127.0.0.1:8747/api/health`
2. **可用 → 用 task-run 派发**（推荐）：
   ```bash
   python3 ~/tools/taskdeck/task-run.py \
     --name "短标题" \
     --goal "大白话写给用户看：这个脚本干嘛、预计多久、产出什么" \
     --max-minutes 120 \
     -- <命令>
   ```
   - `--goal` **必须用大白话写**（用户在面板上靠它理解脚本在干嘛）。
   - 派发后**把详情页 URL 告诉用户**；监控看 TaskDeck 面板（http://127.0.0.1:8747/ ，自动判卡死/空转/超期），agent 不做轮询盯梢。
   - **汇报时体检**：到检查点/任何汇报点，用 `curl -s http://127.0.0.1:8747/api/tasks` 汇总本批后台任务的健康状态（运行中 / 疑似卡死 / 疑似空转 / 超期 / 已结束），写进大白话汇报的「有没有坏消息」。
3. **不可用（换台设备/没装）→ 先尝试自装 TaskDeck**（公开仓库 + 一键安装器，含开机自启）：
   ```bash
   git clone --depth 1 https://github.com/tiancai4652/taskdeck /tmp/taskdeck \
     && bash /tmp/taskdeck/install.sh && rm -rf /tmp/taskdeck
   ```
   装完再探活 → 可用则按上面用 task-run（服务与 task-run 立即生效；skill 说明本会话可能需重启 opencode 才被识别，不影响派发）。
4. **自装也失败（无网络/无 python3 等）→ 回退到带日志的后台**，**不得因此卡住，也不得静默裸跑**：
   ```bash
   mkdir -p docs/runs/NNN-<功能名>/logs
   nohup <命令> > docs/runs/NNN-<功能名>/logs/<名字>.log 2>&1 &
   echo $! > docs/runs/NNN-<功能名>/logs/<名字>.pid
   ```
   - 告知用户：「本机无 TaskDeck 面板，任务已在后台运行，日志在 `<路径>`」。
   - 汇报时说明"无面板，请按需查看日志"；到检查点用 `ps -p $(cat <pid文件>)` 判断是否还在跑。
5. 无人值守 `loop.sh` 同样按上面规则启动（有 TaskDeck 走 task-run，没有就 nohup + 日志）。

## 需求批判门控（硬性，v4 核心）

PRD 交给用户确认**之前**，pm 必须对需求本身做一次对抗性审查（防"确认了伪需求"）：

1. **调 `RedTeam` skill（轻量单轮）**：对当前 PRD 产出「**3 个最强反驳 + 推荐**」（每个反驳一句大白话：这个需求可能不成立在哪 / 有没有更本质的解法 / 用户真正要的是不是别的）。
2. **连 PRD 一起交给用户**：用户看完反驳再拍板——确认、修改、或推翻重来。
3. **跳过条件**：明确的小改动、指令式任务（"把按钮改红"）、用户已给出确定方案 → 跳过，不打扰。
4. **缺失降级**：RedTeam 不可用 → pm 自查三问并写进 PRD 给用户看：①这是真需求还是伪需求？②有没有更简单的解法？③用户真正想要的结果是什么？
5. 批判结论记入 `DECISIONS.md`（带轮次标记）+ 本轮 PRD 的「需求批判」小节。

## 设计链路（硬性，v4 核心，自动分级）

任务涉及前端/UI（页面、组件、仪表盘、落地页、样式、移动端界面）时，**写任何界面代码之前**：

**判级（自动，先做）**：engineer 按任务类型自动判 L1/L2，判完**一句话告知用户**并写进 PRD「UI/UX 设计决策」默认级别；用户可随时改判。
- **L1**：改样式 / 换文案 / 调布局 / 单个组件 → 轻量路径。
- **L2**：新页面 / 落地页 / 仪表盘 / 整站视觉 / 大改 → 全链路。
- 拿不准 → 按 L2 走（宁可多做一点，别漏了方向确认）。

**L1 轻量路径**：
1. 调 `ui-ux-pro-max` 检索风格/配色/字体/UX 规范（单个组件走 domain 检索）。
2. 给 2~3 个口语化候选（"长什么样、什么感觉" + 推荐 + 理由），`[[NEEDS-USER]]` 停下确认。
3. 选定 → 记入 PRD「UI/UX 设计决策」+ DECISIONS → 实现。

**L2 全链路**：
1. 调 `ui-ux-pro-max` 检索（新页面走 design-system 检索）→ 定视觉方向（风格/配色/字体/UX）。
2. 调 `Webdesign` skill：把设计落成规范（设计 token：颜色变量/字体/间距 + 整体视觉方向 + 实现路径）。
3. **加重触发**（满足任一即加跑）：大改 / 落地页 / 仪表盘，或用户说"想先看到样子" → 调 `huashu-design` 出 2~3 方向 **HTML 高保真原型**，让用户先看到真实样子再拍板。
4. 产出设计方案（大白话：长什么样、什么感觉 + 推荐 + 理由），`[[NEEDS-USER]]` 停下等拍板。
5. （可选）`RedTeam` 对设计方案批一轮（大改时建议做）。
6. 选定 → 记入 PRD「UI/UX 设计决策」+ DECISIONS → 实现遵守该基线，不再重复询问。

**依赖矩阵（探活 → 缺则自装 → 装不了降级，全部非硬依赖）**：

**探活要多根**（skill 可能装在不同位置，只查一个根会误判缺失、重复自装）：
```bash
for r in ~/.config/opencode/skills ~/.opencode/skills ~/.claude/skills; do
  [ -f "$r/<名字>/SKILL.md" ] && echo "FOUND: $r/<名字>"
done
```
命中任一即视为已装（直接用）；都没有才自装，**安装目标统一为 `~/.config/opencode/skills/`**。

| skill | 自装命令（实测过的路径） | 缺失时降级 |
|---|---|---|
| ui-ux-pro-max | `git clone --depth 1 https://github.com/nextlevelbuilder/ui-ux-pro-max-skill /tmp/uiux && cp -R /tmp/uiux/.claude/skills/ui-ux-pro-max ~/.config/opencode/skills/ && rm -rf /tmp/uiux`（MIT） | 用常识给 2~3 个口语化风格候选 |
| Webdesign | `git clone --depth 1 https://github.com/danielmiessler/LifeOS /tmp/lifeos && cp -R /tmp/lifeos/LifeOS/install/skills/Webdesign ~/.config/opencode/skills/ && rm -rf /tmp/lifeos`（**只拷这一个文件夹，不装整个 LifeOS**） | engineer 自行按方向写 |
| huashu-design | `git clone --depth 1 https://github.com/alchaincyf/huashu-design /tmp/huashu && rm -f /tmp/huashu/assets/bgm-*.mp3 && rm -rf /tmp/huashu/.git /tmp/huashu/demos && cp -R /tmp/huashu ~/.config/opencode/skills/huashu-design && rm -rf /tmp/huashu`（**只删 BGM mp3，保留 assets 里的 jsx/svg 组件**） | 跳过高保真，用文字方案 |
| RedTeam | `git clone --depth 1 https://github.com/danielmiessler/LifeOS /tmp/lifeos && cp -R /tmp/lifeos/LifeOS/install/skills/RedTeam ~/.config/opencode/skills/ && rm -rf /tmp/lifeos` → **装后跑本 skill 目录下的 `assets/sanitize-lifeos-skill.sh ~/.config/opencode/skills/RedTeam`**（剥语音通知 + 中和 LifeOS 日志路径） | pm 自查三问 |
| PM Skills | `git clone --depth 1 https://github.com/deanpeters/Product-Manager-Skills /tmp/pmskills && cp -R /tmp/pmskills/skills/* ~/.config/opencode/skills/ && rm -rf /tmp/pmskills`（仓库 `skills/` 下是 77 个 skill，一次全装） | pm 裸聊，不阻塞 |
| **TaskDeck**（后台服务，非 skill） | `git clone --depth 1 https://github.com/tiancai4652/taskdeck /tmp/taskdeck && bash /tmp/taskdeck/install.sh && rm -rf /tmp/taskdeck`（Python3 stdlib 零依赖，跨 mac/Linux/Win；默认注册开机自启） | 回退 `nohup` + 本轮目录日志（见「后台长任务」步骤 4） |

**LifeOS 系 skill（Webdesign / RedTeam 等）装后必做**：跑本 skill 目录下的 `assets/sanitize-lifeos-skill.sh <目录>`（完整路径如 `~/.config/opencode/skills/checkpoint-agent-loop-v4/assets/sanitize-lifeos-skill.sh`）——否则它们自带「强制语音通知 POST localhost:31337」（无此服务会空跑/报错）和 LifeOS 专属日志路径。

**自装通用规则**（skill 类）：装完先试调 `skill` 工具；当前会话加载不到（skill 列表随 opencode 启动载入，新装的要重启才生效）→ 本轮走降级路径，并提醒用户"已装好，重启 opencode 后可用"。无网络 / git 失败 → 直接降级，不阻塞、不硬扛、不编造检索结果。
**TaskDeck 例外**（它不是 skill）：`install.sh` 装完直接探活 `http://127.0.0.1:8747/api/health` 即可用，不依赖 `skill` 工具、不需重启 opencode。

**Webdesign 能力边界**：其 DirectDesign 路径自包含可用；但 `/design`、`/design-sync`、ClaudeDesign 三条路径依赖 LifeOS harness / claude.ai，非 LifeOS 环境只有部分能力——够用即可，缺的能力按降级处理。

**例外**：用户已在 PRD「UI/UX 设计决策」里确认过设计基线 → 跳过询问，直接遵守基线。

## 超时默认（10 分钟无回复 → 按推荐继续）

停到 `[[CHECKPOINT]]` / `[[NEEDS-USER]]` 后，若用户 **10 分钟内未回复**：
1. **不空等**：按评审汇报中的**推荐方案**继续执行（超时默认）。推荐方案已在评审时用第一性原理分析过，走它 = 有依据的默认前进，不是瞎猜。
2. **留痕**：在 `DECISIONS.md` 记一条（带轮次标记）：`[NNN-<功能名>] 日期：检查点超时默认 → 采用推荐方案X（理由见本轮 CHECKPOINT-REPORT）`。
3. **用户后到优先**：用户稍后的批复与推荐方案冲突时，以用户批复为准，按其指示回滚/调整。
4. **硬性关卡不适用**：初始化确认关卡（PRD 未确认）、需求批判门控、设计链路 L2 首次拍板（含 huashu 高保真选型）绝不超时默认，必须等到用户明确拍板。

## 强制沉淀（每个 [[CHECKPOINT]] 必做）

到达检查点时，除写 `docs/runs/NNN-<功能名>/CHECKPOINT-REPORT.md`（本轮目录，经根指针 `CHECKPOINT-REPORT.md` 访问）外，**必须执行**：
1. 回顾本段任务：有无新知识 / 新约定 / 踩过的坑 / 新技术决策？
2. **有 → 分主题写进 `docs/decisions-archive/<主题>.md`（不是平铺，跨轮共享）**，并引用该文件到 `DECISIONS.md`（一条带轮次标记：`[NNN-<功能名>] 日期：本任务沉淀 → 见 docs/decisions-archive/<主题>.md`）
3. **没有 → 也要记一句"本轮无新知识可沉淀"**（强制走判断，非可选项）

## 门控原理

engineer 到里程碑必须印 `[[CHECKPOINT]]`；驱动循环据此用机器可判断的签名决定"停/走"。这是 RALPH 式门控，最薄、最好调试。

## 无人值守（可选）

用 task-run 派发 loop 脚本反复调 `opencode run --session <id> --continue --agent engineer "继续执行 PRD.md 当前任务"`（PRD.md 是根指针，指向本轮 run 目录），并 grep 输出签名决定是否 break。脚本本身在 TaskDeck 面板可见、可判健康。
