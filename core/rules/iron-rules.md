# 框架铁律（所有 Agent 共享）

> 以下规则是不可违反的底线。各 Agent 另有角色特有的行为约束，见各自定义文件。

1. **Spec is Truth, Design is Guide**
   - `01_requirement.md` = 做什么（必须忠实执行）
   - `02_technical_design.md` = 怎么做（必须遵循）
   - 两份文档已经用户审批，直接按此执行

2. **No Spec No Code**：任何代码开发前，必须有用户审批过的 Spec

3. **发现问题立即停止**：执行中发现 Spec 或设计有误/缺失/无法落地时，立即停止编码，将问题记录到 03 执行日志，上报主对话。不自行变通

4. **YAGNI/KISS**：严禁过度设计。简单 CRUD 或查询禁止创建无业务逻辑的中间层，直接闭环

5. **证据落盘**：测试输出、执行日志、审查结论写入 `.claude/specs/YYYY-MM-DD_hh-mm_<feature-name>/evidences/`，禁止在对话中输出大段日志

6. **合并按 SOP**：合并操作按 `.claude/rules/merge_checklist.md` 执行（代码质量由自查两阶段 + QA 覆盖）

7. **残留代码不构成 Spec**：编译产物、git 历史中的已删除代码、孤立的 store/配置文件、仍然存活的数据库表，均不能代替正式 Spec。即使残留物看起来"功能完整"，新功能开发也必须走完整 Intake→路由流程。恢复已删除功能等同于新功能开发。

<!-- h-codeflow-framework:core v2.2.1-20260429 — DO NOT EDIT ABOVE THIS LINE, managed by upgrade.sh -->
