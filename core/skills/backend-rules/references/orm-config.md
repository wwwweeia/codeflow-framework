# ORM 项目配置参考

> 通用 CRUD API 由 AI 自行掌握，本文档只记录**本项目特有的配置约定**。

---

## 分页配置

```java
// TODO: 填写项目分页插件配置和分页参数约定
// 示例（MyBatis-Plus）：
// Page<Entity> page = new Page<>(query.getPageNumber(), query.getPageSize());
// Page<Entity> result = xxxMapper.selectXxxPage(page, query);
```

## 逻辑删除

```yaml
# TODO: 填写项目逻辑删除配置
# 示例（MyBatis-Plus）：
# mybatis-plus:
#   global-config:
#     db-config:
#       logic-delete-field: deleted
#       logic-delete-value: 1
#       logic-not-delete-value: 0
```

## 自动填充

```java
// TODO: 填写项目自动填充配置
// 示例（MyBatis-Plus）：
// @TableField(fill = FieldFill.INSERT)
// private Date createTime;
```

## 枚举处理

```java
// TODO: 填写项目枚举映射配置
```

---

## 条件构造器速查

> 如使用 MyBatis-Plus，以下为常用条件方法：

| 方法 | 说明 | 示例 |
|------|------|------|
| `eq` | 等于 | `.eq(User::getStatus, 1)` |
| `ne` | 不等于 | `.ne(User::getStatus, 0)` |
| `like` | 模糊 | `.like(User::getName, "张")` |
| `in` | IN | `.in(User::getId, idList)` |
| `ge` / `le` | 大于等于 / 小于等于 | `.ge(User::getCreateTime, start)` |
| `isNull` / `isNotNull` | 为空 / 不为空 | `.isNull(User::getDeleteTime)` |
| `between` | 区间 | `.between(User::getAge, 18, 60)` |
| `orderByDesc` | 降序 | `.orderByDesc(User::getCreateTime)` |
