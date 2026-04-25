# Spec Lite Template

spec 是持久化上下文与压缩记忆层；没有最小 spec，不进入代码实现。

```markdown
# Spec: <Task Name>

## Goal
- 要解决什么问题：
- 验收结果：

## Done Contract
- 什么算完成：
- 由什么证明：
- 哪些情况仍算未完成：

## Scope
- In:
- Out:

## Facts / Constraints
- 已确认事实：
- 技术/业务约束：
- 已知风险：

## Open Questions
- [ ] 待确认项 1

## Restated Understanding
- 我理解当前任务是：
- 当前核心目标是：
- 当前边界是：
- 暂不处理：

## Goal Alignment Check
- 当前动作是否仍服务于核心目标：
- 若否，偏差在哪里：
- 是否需要调整本轮目标或范围：

## Checkpoint Summary
- 当前任务理解：
- 当前核心目标：
- 当前进度：
- 下一步 1:
- 下一步 2:
- 涉及文件 / 模块：
- 风险：
- 验证方式：
- Execution Approval: `Pending` / `Approved`

## Change Log
- YYYY-MM-DD: 决策/改动摘要

## Validation
- Self-check:
- Static checks:
- Runtime / Test:
- Human confirmation:
- 结果汇总：
- 核心目标是否已由证据证明完成：
- 若未完成，当前剩余差距：
- 剩余风险：

## Resume / Handoff
- 当前状态：
- 当前卡点：
- 下一步唯一动作：
- 下一轮核心目标：
```

建议：

- `fast` 任务也至少保留 `Goal / Done Contract / Restated Understanding / Checkpoint Summary / Approval / Change Log / Validation / Resume / Handoff`。
- `standard` 任务通常补齐全部区块即可。
- `deep` 任务在此基础上扩展，但仍避免写成巨型 spec。
- spec 一旦形成或更新，应尽快落盘。
- 用户输入任务后，先写 `Restated Understanding`，再进入后续动作。
- `Done Contract` 保持 1-3 行，优先写“完成定义 + 证明来源”，不要写成长计划。
- `Checkpoint Summary` 里要明确区分：`任务理解`、`核心目标`、`当前进度`，不要混写成一个概念。
- `Goal Alignment Check` 用于记录“当前动作是否还在服务核心目标”；出现日志、测试或人工反馈后优先更新这里。
- `Validation` 优先记录外部证据，模型自检只能作为补充，不能替代测试、运行结果或人工确认。
- 执行前先把 `Execution Approval` 置为 `Pending`，获批后再改为 `Approved`。
- 暂停、切换任务点或准备交接前，更新 `Resume / Handoff`，确保下一轮可以快速恢复。
- 编码前、切换任务点前、收尾前，回读当前相关区块，不整份重载。
