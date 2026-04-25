---
layout: home

hero:
  name: CodeFlow
  text: 确定性优先的 AI 开发框架
  tagline: Spec-Driven Development — 先确认再执行，让 AI 在确定性空间里高速运转
  actions:
    - theme: brand
      text: 快速入门
      link: /guide/quick-start
    - theme: alt
      text: 设计理念
      link: /guide/philosophy
    - theme: alt
      text: 架构概览
      link: /design/overview

features:
  - icon: 📋
    title: Spec 驱动，No Spec No Code
    details: 需求确认 → 设计确认 → AI 执行。所有不确定性在写代码之前消除，而不是在返工中暴露。
  - icon: 🤖
    title: 7 Agent 专业分工
    details: PM、架构师、后端、前端、QA、原型、E2E — 角色职责明确，按工作流自动编排协作。
  - icon: ⚡
    title: 零依赖，基于原生配置
    details: 不引入运行时，纯文件分发。基于 Claude Code 原生 CLAUDE.md / Agents / Rules / Commands 机制。
  - icon: 🔄
    title: 双向同步，持续进化
    details: upgrade.sh 向下推送标准，harvest.sh 向上收割实战经验。框架与项目共同成长。
  - icon: 🛡️
    title: 内置质量门禁
    details: 合并检查清单、Spec 格式校验、代码审查规则 — 每个环节都有自动化质量保障。
  - icon: 🏗️
    title: 渐进式采纳
    details: 从单项目轻量接入到团队全面推广。四个工作流（Q0/A/B/C）覆盖从 bug fix 到全栈联动的所有场景。
---

<div class="why-framework">
  <div class="wf-header">
    <h2>为什么是框架，不是插件？</h2>
    <p>Claude Code 有多种扩展方式，CodeFlow 选择了最轻量、最原生的一种。</p>
  </div>

  <div class="wf-layers">
    <div class="wf-layer">
      <div class="wf-layer-badge">运行时</div>
      <div class="wf-layer-content">
        <h4>MCP Server</h4>
        <p>给 Claude 增加新工具能力（外部进程），需要独立开发维护</p>
      </div>
    </div>
    <div class="wf-layer">
      <div class="wf-layer-badge">事件层</div>
      <div class="wf-layer-content">
        <h4>Hooks</h4>
        <p>事件驱动脚本（如提交前自动检查），适合自动化检查点</p>
      </div>
    </div>
    <div class="wf-layer wf-layer-active">
      <div class="wf-layer-badge active">配置层 ← CodeFlow 在这里</div>
      <div class="wf-layer-content">
        <h4>CLAUDE.md · Agents · Rules · Commands</h4>
        <p>纯文本指令，Claude 直接读取执行。零运行时、零依赖、开箱即用</p>
      </div>
    </div>
    <div class="wf-layer">
      <div class="wf-layer-badge">记忆层</div>
      <div class="wf-layer-content">
        <h4>Memory</h4>
        <p>跨会话持久化上下文，记录用户偏好和项目经验</p>
      </div>
    </div>
  </div>

  <div class="wf-compare">
    <div class="wf-compare-col">
      <h4>🔧 插件思维</h4>
      <ul>
        <li>需要安装、注册、版本管理</li>
        <li>引入运行时依赖（MCP 进程、npm 包）</li>
        <li>绑定特定 Claude Code 版本</li>
        <li>解决的是"能力扩展"问题</li>
      </ul>
    </div>
    <div class="wf-compare-col highlight">
      <h4>🏗️ 框架思维</h4>
      <ul>
        <li>文件即配置，upgrade.sh 一键同步</li>
        <li>零运行时，不引入任何外部依赖</li>
        <li>跟 Claude Code 一起自然演进</li>
        <li>解决的是"团队协作方式"问题</li>
      </ul>
    </div>
  </div>

  <div class="wf-footer">
    <p>框架不替代 Claude Code 的能力，而是<strong>定义团队如何使用这些能力</strong>——规范工作流、明确角色分工、统一质量标准。</p>
  </div>
</div>

<style>
.why-framework {
  max-width: 960px;
  margin: 96px auto 0;
  padding: 0 24px 0;
}

.wf-header {
  text-align: center;
  margin-bottom: 48px;
}
.wf-header h2 {
  font-size: 24px;
  font-weight: 600;
  margin-bottom: 12px;
  background: -webkit-linear-gradient(120deg, #4f46e5, #0ea5e9);
  -webkit-background-clip: text;
  -webkit-text-fill-color: transparent;
}
.wf-header p {
  color: var(--vp-c-text-2);
  font-size: 16px;
}

/* Layers */
.wf-layers {
  display: flex;
  flex-direction: column;
  gap: 12px;
  margin-bottom: 48px;
}
.wf-layer {
  display: flex;
  align-items: center;
  gap: 16px;
  padding: 16px 20px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
  transition: border-color 0.3s, box-shadow 0.3s;
}
.wf-layer-active {
  border-color: #4f46e5;
  box-shadow: 0 0 0 1px #4f46e5, 0 4px 12px rgba(79, 70, 229, 0.15);
  background: var(--vp-c-bg-soft);
}
.wf-layer-badge {
  flex-shrink: 0;
  padding: 4px 12px;
  border-radius: 4px;
  font-size: 12px;
  font-weight: 600;
  background: var(--vp-c-default-soft);
  color: var(--vp-c-text-2);
  white-space: nowrap;
}
.wf-layer-badge.active {
  background: #4f46e5;
  color: #fff;
}
.wf-layer-content h4 {
  font-size: 14px;
  font-weight: 600;
  margin-bottom: 4px;
}
.wf-layer-content p {
  font-size: 13px;
  color: var(--vp-c-text-2);
  margin: 0;
}

/* Compare */
.wf-compare {
  display: grid;
  grid-template-columns: 1fr 1fr;
  gap: 24px;
  margin-bottom: 48px;
}
.wf-compare-col {
  padding: 24px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
}
.wf-compare-col.highlight {
  border-color: #4f46e5;
  box-shadow: 0 4px 12px rgba(79, 70, 229, 0.1);
}
.wf-compare-col h4 {
  font-size: 16px;
  font-weight: 600;
  margin-bottom: 16px;
}
.wf-compare-col ul {
  list-style: none;
  padding: 0;
  margin: 0;
}
.wf-compare-col li {
  position: relative;
  padding-left: 20px;
  margin-bottom: 10px;
  font-size: 14px;
  color: var(--vp-c-text-2);
  line-height: 1.6;
}
.wf-compare-col li::before {
  content: '';
  position: absolute;
  left: 0;
  top: 9px;
  width: 6px;
  height: 6px;
  border-radius: 50%;
  background: var(--vp-c-text-3);
}
.wf-compare-col.highlight li::before {
  background: #4f46e5;
}

/* Footer */
.wf-footer {
  text-align: center;
  padding: 24px;
  border-radius: 8px;
  background: var(--vp-c-bg-soft);
}
.wf-footer p {
  font-size: 15px;
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.8;
}

@media (max-width: 640px) {
  .wf-compare {
    grid-template-columns: 1fr;
  }
  .wf-layer {
    flex-direction: column;
    align-items: flex-start;
    gap: 8px;
  }
}
</style>
