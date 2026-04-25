# XML Mapper 代码模板

## Mapper 接口

```java
package com.example.xxx.mapper;

import com.example.xxx.entity.Xxx;
import com.example.xxx.query.XxxQuery;
import org.apache.ibatis.annotations.Param;

import java.util.List;
import java.util.Set;

/**
 * Xxx Mapper 接口
 *
 * TODO: 如项目使用 MyBatis-Plus，继承 BaseMapper<Xxx>
 */
public interface XxxMapper {

    /**
     * 分页查询（返回 Entity，Service 层转 VO）
     *
     * TODO: 如使用 MyBatis-Plus 分页，第一参数为 Page<Xxx>
     */
    List<Xxx> selectXxxPage(@Param("query") XxxQuery query);

    /**
     * 批量插入
     */
    int batchInsert(@Param("list") List<Xxx> list);

    /**
     * 根据 ID 集合查询
     */
    List<Xxx> selectListByIds(@Param("collection") Set<Long> ids);
}
```

### 关键约定

| 约定 | 说明 |
|------|------|
| 分页参数 | TODO: 填写分页参数类型（如 `Page<Entity>`） |
| 查询参数 | `@Param("query") XxxQuery`（一个 query 对象，非拆散的单字段） |
| 返回类型 | Entity（Service 层负责转 VO，Mapper 不直接返回 VO） |

---

## 标准 Mapper XML

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE mapper PUBLIC "-//mybatis.org//DTD Mapper 3.0//EN"
        "http://mybatis.org/dtd/mybatis-3-mapper.dtd">
<mapper namespace="com.example.xxx.mapper.XxxMapper">

    <!-- 分页查询（返回 Entity） -->
    <select id="selectXxxPage" resultType="com.example.xxx.entity.Xxx">
        SELECT *
        FROM xxx
        <where>
            <if test="query.name != null and query.name != ''">
                AND name LIKE CONCAT('%', #{query.name}, '%')
            </if>
            <if test="query.status != null and query.status != ''">
                AND status = #{query.status}
            </if>
        </where>
        ORDER BY update_time DESC
    </select>

</mapper>
```

### 关键约定

| 约定 | 说明 |
|------|------|
| `resultType` | 用 `resultType` 指向 Entity，字段与列名由框架自动驼峰映射 |
| 查询条件 | 全部通过 `query.xxx` 引用，用 `<if>` 动态拼接 |
| 表名前缀 | TODO: 填写项目表名前缀（如 `ai_`、`sys_`） |

---

## 批量操作模板

```xml
<!-- 批量插入 -->
<insert id="batchInsert" parameterType="java.util.List">
    INSERT INTO xxx (name, status, create_time, update_time)
    VALUES
    <foreach collection="list" item="item" separator=",">
        (#{item.name}, #{item.status}, NOW(), NOW())
    </foreach>
</insert>
```

---

## 复杂联表查询模板

```xml
<!-- 一对多：主表 + 子表 -->
<select id="selectWithDetail" resultMap="WithDetailResultMap">
    SELECT
        a.id, a.name, a.status,
        d.id as detail_id, d.item_name, d.item_value
    FROM xxx a
    LEFT JOIN xxx_detail d ON a.id = d.xxx_id
    WHERE a.id = #{id}
</select>

<resultMap id="WithDetailResultMap" type="com.example.xxx.vo.XxxDetailVO">
    <id column="id" property="id"/>
    <result column="name" property="name"/>
    <result column="status" property="status"/>
    <collection property="details" ofType="com.example.xxx.vo.XxxDetailItemVO">
        <id column="detail_id" property="id"/>
        <result column="item_name" property="itemName"/>
        <result column="item_value" property="itemValue"/>
    </collection>
</resultMap>
```

> **注意**：只有在需要联表 + 嵌套结果映射时才使用 `resultMap`。单表查询优先使用 `resultType`。
