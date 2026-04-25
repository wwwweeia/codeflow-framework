# Controller 代码模板

> 本文件提供标准 REST Controller 的代码模板，包含 Controller、DTO、Query、VO 四件套。
> 请根据项目实际的包名、基类、响应对象替换模板中的占位内容。

## 标准 REST Controller

```java
package com.example.xxx.controller;

import com.example.xxx.dto.XxxDTO;
import com.example.xxx.query.XxxQuery;
import com.example.xxx.service.XxxService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.validation.annotation.Validated;
import org.springframework.web.bind.annotation.*;

import javax.validation.Valid;
import javax.validation.constraints.NotNull;
import java.util.List;

/**
 * Xxx 管理控制器
 */
@RestController
@RequestMapping("/api/xxx")
@Validated
public class XxxController {

    @Autowired
    private XxxService xxxService;

    /**
     * 分页查询
     */
    @PostMapping("/list")
    public R getList(@RequestBody XxxQuery query) {
        return xxxService.getList(query);
    }

    /**
     * 根据 ID 查询
     */
    @GetMapping("/{id}")
    public R getById(@PathVariable @NotNull(message = "ID不能为空") Long id) {
        return xxxService.getById(id);
    }

    /**
     * 创建
     */
    @PostMapping
    public R create(@RequestBody @Valid XxxDTO dto) {
        return xxxService.create(dto);
    }

    /**
     * 更新
     */
    @PutMapping("/{id}")
    public R update(
            @PathVariable @NotNull(message = "ID不能为空") Long id,
            @RequestBody @Valid XxxDTO dto) {
        return xxxService.update(id, dto);
    }

    /**
     * 删除（支持批量）
     */
    @DeleteMapping
    public R delete(@RequestParam List<Long> ids) {
        return xxxService.delete(ids);
    }
}
```

### 关键约定

| 约定 | 说明 |
|------|------|
| 返回值 | TODO: 填写项目统一返回值类型 |
| 依赖注入 | TODO: `@Autowired` 字段注入 or 构造器注入 |
| 分页查询 | TODO: 填写分页接口约定 |
| 路径前缀 | TODO: 填写路径前缀规范 |
| 校验 | `@Validated` 在类上，`@Valid` 在参数上 |

---

## DTO 模板

```java
package com.example.xxx.dto;

import lombok.Data;
import javax.validation.constraints.*;

/**
 * Xxx DTO
 */
@Data
public class XxxDTO {

    @NotBlank(message = "名称不能为空")
    @Size(max = 100, message = "名称长度不能超过100")
    private String name;

    @Size(max = 500, message = "描述长度不能超过500")
    private String description;
}
```

---

## Query 模板

```java
package com.example.xxx.query;

import lombok.Data;

/**
 * Xxx 查询参数
 *
 * TODO: 如项目有 BasePageParam 基类，请继承它
 */
@Data
public class XxxQuery {

    private String name;

    private String status;
}
```

---

## VO 模板

```java
package com.example.xxx.vo;

import lombok.Data;
import java.util.Date;

/**
 * Xxx VO
 */
@Data
public class XxxVO {

    private Long id;

    private String name;

    private String status;

    private String description;

    private Date createTime;

    private Date updateTime;
}
```
