回顾本次会话中的非显而易见决策，更新项目长期记忆（可选）。

## 执行步骤

1. 读取 Claude 自动 memory 索引（`~/.claude/projects/*/memory/MEMORY.md`）
2. 回顾本次会话中的关键信息，提炼值得保留的内容：
   - 关键决策及其原因（为什么选 A 不选 B）
   - 排坑经验（下次可复用的教训）
   - 用户偏好变化（协作方式、代码风格等）
   - 项目状态变化（架构调整、依赖升级、流程变更等）
3. 检查是否已有相关 memory，有则更新，无则新建
4. 写入 Claude 自动 memory 目录（每条 memory 独立文件 + 更新 MEMORY.md 索引）

## 不记录
- 代码细节、文件路径、git 历史（可从代码/git 推断）
- 临时进度状态（属于 todo，不属于 memory）
- CLAUDE.md 中已有的规则（避免重复）

## memory 类型参考
- **user**：用户角色、偏好、知识背景
- **feedback**：用户对协作方式的纠正或认可
- **project**：项目进展、决策、里程碑
- **reference**：外部系统的指针（Linear、Grafana、文档链接等）

用户提示（如有）：$ARGUMENTS

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
