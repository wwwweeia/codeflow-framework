---
name: sdd-riper-one-light
description: 轻量 spec-driven / checkpoint-driven coding skill。用于高频、多轮的代码任务，强调最小 spec、先复述理解、执行前 checkpoint、明确批准、执行后回写。
---

# SDD-RIPER-ONE Light

## 核心定位

- 面向强模型，默认自行分解任务、补足局部计划、按需追溯上下文。
- 主协议只保留少数高杠杆锚点，其余规范按需查看。
- 目标是减少低价值常驻 token，而不是减少控制力。
- Spec 的第一受众是人类（持久化的任务上下文），第二受众才是模型。

## 硬约束

- `Spec is Truth`：spec 是持久化上下文、压缩记忆与协作真相源。
- `No Spec, No Code`：未形成或更新最小 spec 前，不进入代码实现。
- `No Approval, No Execute`：未得到明确执行许可，不进入实现或高影响变更。
- `Restate First`：用户输入任务后，先用模型自己的话复述理解，再进入 spec 或计划。
- `Checkpoint Before Execute`：实现前必须给一次短 checkpoint，确认理解、目标、下一步、风险与验证方式。
- `Done by Evidence`：完成应由验证结果与外部反馈证明。
- `Reverse Sync`：执行后必须把结果、偏差、验证结论回写 spec。

## 最小工作流

1. **理解**：用模型自己的话复述用户任务，确保核心目标强一致
2. **Spec**：用最小 spec 固化目标、边界、计划与验证方式
3. **Checkpoint**：实现前给一次短 checkpoint（理解 + 目标 + 下一步 + 风险）
4. **批准**：等待用户明确批准
5. **执行**：进行代码实现
6. **回写**：执行后回写结果、偏差、验证结论

## 任务深度

- **零 Spec**：纯机械改动（typo、日志、配置），直接执行并 summary
- **快速 (Fast)**：1-3 句写清目标、文件、风险、验证方式，获批后执行
- **标准 (Standard)**：默认模式，维护轻量 spec，执行前 checkpoint，回写结论
- **深度 (Deep)**：需求模糊、架构改动等，显式分析并获批后再实施

## 何时暂停

- 需求存在关键歧义
- 需要破坏性/高风险操作
- 涉及架构/接口/数据模型变更
- 尚未形成最小 spec 或未得到明确执行许可

<!-- codeflow-framework:core v1.7.1-20260420 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
