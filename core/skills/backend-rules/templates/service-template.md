# Service 代码模板

## 标准 Service 接口

```java
package com.example.xxx.service;

import com.example.xxx.dto.XxxDTO;
import com.example.xxx.query.XxxQuery;

import java.util.List;

/**
 * Xxx 服务接口
 */
public interface XxxService {

    R getList(XxxQuery query);

    R getById(Long id);

    R create(XxxDTO dto);

    R update(Long id, XxxDTO dto);

    R delete(List<Long> ids);
}
```

### 关键约定

| 约定 | 说明 |
|------|------|
| 返回值 | TODO: 填写项目统一返回值类型 |
| 分页参数 | TODO: 填写分页基类及字段名 |
| 批量删除 | `delete(List<Long> ids)` 而非 `delete(Long id)` |

---

## 标准 Service 实现

```java
package com.example.xxx.service.impl;

import com.example.xxx.dto.XxxDTO;
import com.example.xxx.entity.Xxx;
import com.example.xxx.mapper.XxxMapper;
import com.example.xxx.query.XxxQuery;
import com.example.xxx.service.XxxService;
import com.example.xxx.vo.XxxVO;
import org.springframework.beans.BeanUtils;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.*;

/**
 * Xxx 服务实现
 *
 * TODO: 如项目使用 MyBatis-Plus，继承 ServiceImpl<XxxMapper, Xxx>
 */
@Slf4j
@Service
public class XxxServiceImpl implements XxxService {

    @Autowired
    private XxxMapper xxxMapper;

    @Override
    public R getList(XxxQuery query) {
        // TODO: 按项目分页约定实现
        // 1. 构建分页参数
        // 2. 调用 Mapper 分页查询
        // 3. Entity 转 VO
        // 4. 构建分页响应返回
        return null;
    }

    @Override
    public R getById(Long id) {
        // TODO: 查询 + 空值检查
        return null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public R create(XxxDTO dto) {
        Xxx entity = new Xxx();
        BeanUtils.copyProperties(dto, entity);
        // TODO: 设置审计字段（createTime/updateTime/createUname/updateUname）
        // TODO: 保存并返回
        return null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public R update(Long id, XxxDTO dto) {
        // TODO: 查询现有记录 + 空值检查
        // TODO: 属性拷贝 + 设置审计字段
        // TODO: 更新并返回
        return null;
    }

    @Override
    @Transactional(rollbackFor = Exception.class)
    public R delete(List<Long> ids) {
        // TODO: 参数校验 + 引用检查 + 删除
        return null;
    }

    // ==================== 私有方法 ====================

    private XxxVO convertToVO(Xxx entity) {
        if (entity == null) return null;
        XxxVO vo = new XxxVO();
        BeanUtils.copyProperties(entity, vo);
        return vo;
    }
}
```

### 关键约定

| 约定 | 说明 |
|------|------|
| 继承 | TODO: 填写 Service 基类（如 `ServiceImpl<XxxMapper, Xxx>`） |
| 注入 | TODO: `@Autowired` 字段注入 or 构造器注入 |
| 分页返回 | TODO: 填写分页响应构建方式 |
| 审计字段 | TODO: 手动设置 or 自动填充？填写具体方式 |
| 事务 | 写操作加 `@Transactional(rollbackFor = Exception.class)` |
