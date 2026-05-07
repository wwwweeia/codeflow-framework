---
layout: home

hero:
  name: HCodeFlow
  text: 用规范驱动 AI 编码
  tagline: 先写规格再写代码 — 让 AI 按流程交付，而不是按感觉写代码
  actions:
    - theme: brand
      text: 认识 SDD（5 分钟）
      link: /getting-started/what-is-sdd
    - theme: alt
      text: 快速入门（15 分钟）
      link: /getting-started/quick-start
---

<div class="features-section">
  <h2>核心特点</h2>
  <div class="features-grid">
    <div class="feature-card">
      <div class="feature-icon">📋</div>
      <h3>Spec 驱动</h3>
      <p>需求确认 → 设计确认 → AI 执行。不确定性在写代码之前消除，而不是在返工中暴露。</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">🤖</div>
      <h3>7 Agent 专业分工</h3>
      <p>PM、架构师、后端、前端、QA — 角色职责明确，按工作流自动编排协作。</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">⚡</div>
      <h3>零依赖，基于原生配置</h3>
      <p>不引入运行时，纯文件分发。基于 Claude Code 原生机制，开箱即用。</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">🔄</div>
      <h3>双向同步，持续进化</h3>
      <p>upgrade.sh 向下推送标准，harvest.sh 向上收割实战经验。</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">🛡️</div>
      <h3>内置质量门禁</h3>
      <p>合并检查清单、Spec 格式校验、代码审查 — 每个环节都有质量保障。</p>
    </div>
    <div class="feature-card">
      <div class="feature-icon">🏗️</div>
      <h3>渐进式采纳</h3>
      <p>从 Q0 轻量到全栈联动（A/B/C），按需选择，不强制全套。</p>
    </div>
  </div>
</div>

<div class="path-section">
  <div class="path-inner">
    <h2>选择你的路径</h2>
    <div class="path-grid">
      <a href="/getting-started/what-is-sdd" class="path-card">
        <div class="path-card-body">
          <div class="path-card-icon">💡</div>
          <div>
            <h3>我想了解</h3>
            <p>SDD 是什么？为什么 AI 编码需要规矩？</p>
          </div>
        </div>
        <div class="path-card-meta">
          <span class="path-time">5 分钟</span>
          <span class="path-arrow">→</span>
        </div>
      </a>
      <a href="/getting-started/quick-start" class="path-card">
        <div class="path-card-body">
          <div class="path-card-icon">⚡</div>
          <div>
            <h3>我想试试</h3>
            <p>快速跑起来，体验 Q0 轻量工作流</p>
          </div>
        </div>
        <div class="path-card-meta">
          <span class="path-time">15 分钟</span>
          <span class="path-arrow">→</span>
        </div>
      </a>
      <a href="/getting-started/tutorial" class="path-card">
        <div class="path-card-body">
          <div class="path-card-icon">🚀</div>
          <div>
            <h3>我想走完整流程</h3>
            <p>从需求到合并，端到端体验 SDD 工作流</p>
          </div>
        </div>
        <div class="path-card-meta">
          <span class="path-time">30 分钟</span>
          <span class="path-arrow">→</span>
        </div>
      </a>
      <a href="/integration/new-project" class="path-card">
        <div class="path-card-body">
          <div class="path-card-icon">🔌</div>
          <div>
            <h3>我想接入项目</h3>
            <p>把框架接入到我的业务项目中</p>
          </div>
        </div>
        <div class="path-card-meta">
          <span class="path-time">看项目规模</span>
          <span class="path-arrow">→</span>
        </div>
      </a>
      <a href="/getting-started/concepts" class="path-card">
        <div class="path-card-body">
          <div class="path-card-icon">📖</div>
          <div>
            <h3>我想深入理解</h3>
            <p>工作流全貌、七角色、Spec 体系、Marker 机制</p>
          </div>
        </div>
        <div class="path-card-meta">
          <span class="path-time">按需查阅</span>
          <span class="path-arrow">→</span>
        </div>
      </a>
      <a href="/getting-started/faq" class="path-card">
        <div class="path-card-body">
          <div class="path-card-icon">❓</div>
          <div>
            <h3>我有问题</h3>
            <p>常见问题速查，故障排查指南</p>
          </div>
        </div>
        <div class="path-card-meta">
          <span class="path-time">随时查</span>
          <span class="path-arrow">→</span>
        </div>
      </a>
    </div>
  </div>
</div>

<style>
/* ── Features Section ── */
.features-section {
  max-width: 960px;
  margin: 80px auto 0;
  padding: 0 24px;
}
.features-section h2 {
  text-align: center;
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 32px;
  color: var(--vp-c-brand-1);
}
.features-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 20px;
}
.feature-card {
  padding: 24px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  background: var(--vp-c-bg-soft);
  transition: border-color 0.25s, box-shadow 0.25s, transform 0.25s;
}
.feature-card:hover {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 4px 16px rgba(79, 70, 229, 0.12);
  transform: translateY(-2px);
}
.feature-icon {
  width: 40px;
  height: 40px;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 20px;
  background: var(--vp-c-brand-soft);
  border-radius: 8px;
  margin-bottom: 12px;
}
.feature-card h3 {
  font-size: 15px;
  font-weight: 600;
  margin-bottom: 6px;
  color: var(--vp-c-text-1);
}
.feature-card p {
  font-size: 13px;
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.7;
}

/* ── Path Section ── */
.path-section {
  margin-top: 96px;
  padding: 56px 0;
  background: var(--vp-c-bg-soft);
}
.path-inner {
  max-width: 960px;
  margin: 0 auto;
  padding: 0 24px;
}
.path-inner h2 {
  text-align: center;
  font-size: 20px;
  font-weight: 600;
  margin-bottom: 32px;
  color: var(--vp-c-brand-1);
}
.path-grid {
  display: grid;
  grid-template-columns: repeat(3, 1fr);
  gap: 16px;
}
.path-card {
  display: flex;
  flex-direction: column;
  justify-content: space-between;
  padding: 20px;
  border: 1px solid var(--vp-c-divider);
  border-radius: 12px;
  background: var(--vp-c-bg);
  text-decoration: none;
  color: inherit;
  transition: border-color 0.25s, box-shadow 0.25s, transform 0.25s;
}
.path-card:hover {
  border-color: var(--vp-c-brand-1);
  box-shadow: 0 4px 16px rgba(79, 70, 229, 0.12);
  transform: translateY(-2px);
}
.path-card-body {
  display: flex;
  gap: 12px;
  align-items: flex-start;
}
.path-card-icon {
  font-size: 22px;
  flex-shrink: 0;
  margin-top: 2px;
}
.path-card-body h3 {
  font-size: 15px;
  font-weight: 600;
  margin-bottom: 4px;
  color: var(--vp-c-text-1);
}
.path-card-body p {
  font-size: 13px;
  color: var(--vp-c-text-2);
  margin: 0;
  line-height: 1.5;
}
.path-card-meta {
  display: flex;
  align-items: center;
  justify-content: space-between;
  margin-top: 16px;
  padding-top: 12px;
  border-top: 1px solid var(--vp-c-divider);
}
.path-time {
  display: inline-block;
  font-size: 12px;
  font-weight: 500;
  color: var(--vp-c-brand-1);
  background: var(--vp-c-brand-soft);
  padding: 2px 10px;
  border-radius: 10px;
}
.path-arrow {
  font-size: 16px;
  color: var(--vp-c-text-3);
  transition: color 0.25s, transform 0.25s;
}
.path-card:hover .path-arrow {
  color: var(--vp-c-brand-1);
  transform: translateX(3px);
}

/* ── Responsive ── */
@media (max-width: 768px) {
  .features-grid,
  .path-grid {
    grid-template-columns: 1fr;
  }
}
@media (min-width: 769px) and (max-width: 1024px) {
  .features-grid,
  .path-grid {
    grid-template-columns: repeat(2, 1fr);
  }
}
</style>
