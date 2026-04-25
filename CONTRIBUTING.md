# Contributing to CodeFlow Framework

感谢你对 CodeFlow Framework 的关注！欢迎贡献代码、文档或反馈。

## 如何贡献

### 报告问题

在 [GitHub Issues](https://github.com/wwwweeia/codeflow-framework/issues) 中提交 Bug 报告或功能请求。

### 提交代码

1. Fork 本仓库
2. 创建特性分支：`git checkout -b feature/your-feature`
3. 提交改动：`git commit -m "feat: add your feature"`
4. 推送分支：`git push origin feature/your-feature`
5. 创建 Pull Request

### 开发指南

- **修改 `core/` 时**：确保 Stub Marker 存在且位置正确
- **修改 Agent 定义时**：保持 YAML frontmatter 结构
- **修改 `tools/` 时**：在 `demo/` 中验证通过后再提交
- **修改文档时**：同步更新 `docs/` 下的对应文档

### 本地验证

```bash
# 验证脚本语法
bash -n tools/upgrade.sh && bash -n tools/harvest.sh && bash -n tools/release.sh

# 在 demo 中验证框架同步
cd demo && bash ../tools/upgrade.sh --dry-run

# 构建文档站
cd docs && npm install && npm run docs:build
```

## 许可证

本项目采用 MIT 许可证。提交代码即表示你同意你的贡献将在同一许可证下发布。
