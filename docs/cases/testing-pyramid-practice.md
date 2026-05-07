---
title: 测试金字塔实战：HCodeFlow 框架的四层质量防线
description: 从单元测试到 E2E，理解框架 Agent 体系中的测试约束为什么存在、怎么落地、如何协作
---

# 测试金字塔实战：HCodeFlow 框架的四层质量防线

## 背景：为什么测试是工作流的内置环节

HCodeFlow 框架是 AI 驱动的开发工作流。Dev Agent 和 FE Agent 根据已审批的 Spec 自动生成代码，但 AI 生成的代码**看起来总是对的**——语法正确、逻辑通顺、甚至注释齐全。问题在于，"看起来对"不等于"真的对"。

这就是测试在框架中不是可选附加项，而是**工作流的内置环节**的原因：

- **Dev Agent** 强制 TDD 循环（RED → GREEN → REFACTOR），每个 Service 方法必须有对应测试
- **FE Agent** 要求新增 utils / store actions 必须有单元测试
- **QA Agent** 不帮你写测试，而是审计你写的测试是否有效
- **E2E Agent** 在部署后从用户视角做最终验收

本文从框架约束出发，帮你建立对单元测试、集成测试、TDD、E2E 测试的系统性认知。

## 测试金字塔：四层防线总览

```
                    ┌─────────┐
                    │  E2E    │  ← 用户视角验收（Playwright）
                    │  测试   │     负责人：E2E Runner
                   ─┴─────────┴─
                  ┌─────────────┐
                  │  QA 审计    │  ← 测试有效性审查
                  │             │     负责人：QA Agent
                 ─┴─────────────┴─
                ┌─────────────────┐
                │   集成测试       │  ← 组件协作链路验证
                │                 │     负责人：Dev / FE
               ─┴─────────────────┴─
              ┌─────────────────────┐
              │   单元测试 / TDD     │  ← 代码逻辑微观验证
              │                     │     负责人：Dev / FE
              └─────────────────────┘

  测试数量：多 ←────────────────────────→ 少
  运行速度：快 ←────────────────────────→ 慢
  覆盖范围：窄 ←────────────────────────→ 广
```

| 层级 | 目标 | 负责人 | 时机 | 证据产物 |
|------|------|--------|------|---------|
| 单元测试 | 验证单个函数/方法的逻辑正确性 | Dev / FE | 编码过程中 | 测试代码 |
| 集成测试 | 验证组件协作链路（请求→响应） | Dev / FE | 编码过程中 | 测试代码 |
| QA 审计 | 审查测试的覆盖完整性和有效性 | QA Agent | 开发完成后 | `evidence-qa-review.md` |
| E2E 测试 | 验证完整用户流程 | E2E Runner | 部署后 | `evidence-e2e.md` |

## 第一层：单元测试 — 代码逻辑的微观验证

### 什么是单元测试

单元测试是对**最小可测试单元**（一个函数、一个方法）的验证。它的核心特征：

- **隔离**：不依赖外部系统（数据库、网络、文件系统），依赖项用 mock/stub 替代
- **快速**：毫秒级完成，可以在编码过程中频繁运行
- **精确**：失败时能精确定位到哪个函数出了问题

### 框架中的约束

**Dev Agent**（`core/agents/dev-agent.md`）：
> 每个新增 Service 方法至少有一个对应测试（RED-GREEN-REFACTOR 已完成）

**FE Agent**（`core/agents/fe-agent.md`）：
> 新增 utils / store actions 有对应单元测试（测试框架按项目配置）

### 代码示例

假设我们有一个计算订单折扣的 Service 方法：

```java
// OrderService.java
public BigDecimal calculateDiscount(Order order, User user) {
    if (user.getVipLevel() >= 3) {
        return order.getTotal().multiply(new BigDecimal("0.15"));
    }
    if (order.getTotal().compareTo(new BigDecimal("500")) >= 0) {
        return order.getTotal().multiply(new BigDecimal("0.10"));
    }
    return BigDecimal.ZERO;
}
```

对应的单元测试：

```java
// OrderServiceTest.java
class OrderServiceTest {

    @Test
    void should_return_15_percent_for_vip3_and_above() {
        var order = new Order().setTotal(new BigDecimal("100"));
        var user = new User().setVipLevel(3);
        assertEquals(new BigDecimal("15.00"), service.calculateDiscount(order, user));
    }

    @Test
    void should_return_10_percent_for_order_over_500() {
        var order = new Order().setTotal(new BigDecimal("600"));
        var user = new User().setVipLevel(1);
        assertEquals(new BigDecimal("60.00"), service.calculateDiscount(order, user));
    }

    @Test
    void should_return_zero_for_regular_small_order() {
        var order = new Order().setTotal(new BigDecimal("100"));
        var user = new User().setVipLevel(1);
        assertEquals(BigDecimal.ZERO, service.calculateDiscount(order, user));
    }
}
```

三个测试覆盖了三条分支路径。如果将来有人修改了折扣逻辑，这些测试会立即失败，提醒你"改错了"。

## 第二层：集成测试 — 组件协作的链路验证

### 什么是集成测试

单元测试验证单个函数，集成测试验证**多个组件协作**是否正确。在后端项目中，最常见的集成测试是验证 HTTP 请求从 Controller → Service → Mapper 的完整链路。

**与单元测试的区别**：

| 维度 | 单元测试 | 集成测试 |
|------|---------|---------|
| 范围 | 单个函数/方法 | 多组件协作链路 |
| 依赖 | 全部 mock | 部分真实（如数据库、Spring 容器） |
| 速度 | 毫秒级 | 秒级 |
| 发现的问题 | 逻辑错误 | 组件间契约不一致、序列化问题、SQL 错误 |

### 框架中的约束

**Dev Agent**：
> 每个新增 API 端点至少一个 Controller 层集成测试（如 MockMvc），验证请求→Service→响应链路

### 代码示例

```java
// OrderControllerIntegrationTest.java
@SpringBootTest
@AutoConfigureMockMvc
class OrderControllerIntegrationTest {

    @Autowired
    private MockMvc mockMvc;

    @Autowired
    private OrderRepository orderRepository;

    @Test
    void should_create_order_and_return_201() throws Exception {
        mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"productId\":1,\"quantity\":2}"))
            .andExpect(status().isCreated())
            .andExpect(jsonPath("$.orderId").exists())
            .andExpect(jsonPath("$.total").value(200));
    }

    @Test
    void should_return_404_when_product_not_found() throws Exception {
        mockMvc.perform(post("/api/orders")
                .contentType(MediaType.APPLICATION_JSON)
                .content("{\"productId\":99999,\"quantity\":1}"))
            .andExpect(status().isNotFound());
    }
}
```

集成测试发现了单元测试发现不了的问题：JSON 序列化是否正确、路由是否注册、Spring Security 拦截是否正常。

## TDD 实践：先写测试的勇气

### RED → GREEN → REFACTOR 循环

TDD（Test-Driven Development，测试驱动开发）不是"写完代码补测试"，而是**先写测试，再写代码**。

框架的 Dev Agent 将 TDD 作为每个子任务的执行节奏：

```
for 每个子任务（来自 02 的 API/Service/Mapper 拆解）:
  1. RED     — 先写失败测试（描述预期行为，运行确认 FAIL）
  2. GREEN   — 最小实现让测试通过（运行确认 PASS）
  3. REFACTOR — 在测试保护下优化代码结构
```

### 一个完整的 TDD 循环

**第一步 RED — 写一个会失败的测试**：

```java
@Test
void should_calculate_vip_discount() {
    var order = new Order().setTotal(new BigDecimal("100"));
    var user = new User().setVipLevel(3);
    // calculateDiscount 方法还不存在，编译会失败
    var discount = service.calculateDiscount(order, user);
    assertEquals(new BigDecimal("15.00"), discount);
}
```

运行测试：**FAIL**（方法不存在）。这是预期的，RED 阶段的目的就是确认测试能正确地"检测失败"。

**第二步 GREEN — 最小实现让测试通过**：

```java
public BigDecimal calculateDiscount(Order order, User user) {
    return order.getTotal().multiply(new BigDecimal("0.15"));
}
```

运行测试：**PASS**。够了，不要加多余的逻辑。

**第三步 REFACTOR — 在测试保护下优化**：

```java
public BigDecimal calculateDiscount(Order order, User user) {
    if (user.getVipLevel() >= 3) {
        return order.getTotal().multiply(VIP_DISCOUNT_RATE);
    }
    if (order.getTotal().compareTo(BULK_THRESHOLD) >= 0) {
        return order.getTotal().multiply(BULK_DISCOUNT_RATE);
    }
    return BigDecimal.ZERO;
}
```

运行测试：**仍然 PASS**。重构完成，代码更健壮，测试保护你不会改坏。

### 为什么"先写测试"反而更快

直觉上，先写测试多花时间。但实际项目中：

1. **测试即文档**：测试描述了"这个函数应该做什么"，比注释更可靠（因为测试会被运行验证）
2. **设计引导**：写测试时思考的是"调用者需要什么"，而不是"实现者怎么做"，自然导向更好的接口设计
3. **调试时间减少**：每步只改一点，出问题立刻知道是哪一步引入的，不用在几百行代码里大海捞针
4. **重构信心**：有测试保护，敢于重构，代码不会腐化

## 第三层：QA 审计 — 独立的质量审查

### QA 不是帮你写测试

QA Agent 的职责不是替 Dev/FE 写测试，而是**审计已有的测试是否有效**。这模拟了真实团队中 QA 角色的核心价值。

### 审计维度

QA Agent 对照以下四个维度进行审计：

| 维度 | 检查内容 |
|------|---------|
| 覆盖完整性 | 02 Part E 的每个场景，在 04 Part A 矩阵中是否都有对应测试 |
| 测试有效性 | 抽查 2-3 个测试代码，断言是否真的验证了业务规则 |
| 盲区补充 | Dev/Arch 未覆盖但 QA 认为重要的场景 |
| 反模式检查 | "测实现不测行为""测试间共享状态""断言过弱" |

### 测试计划文档的作用

测试计划（`04_test_plan.md`）是测试全链路的**追溯枢纽**：

```
01 需求文档          02 技术设计           04 测试计划           测试代码
┌──────────┐      ┌──────────────┐     ┌────────────────┐    ┌──────────────┐
│ §3.2 用户│ ──→  │ Part E: 场景 │ ──→ │ Part A: 矩阵   │ ──→│ TestClass#   │
│ 可管理设备│      │ 1. 创建设备  │     │ #1 创建设备    │    │ testCreate   │
│          │      │ 2. 重名校验  │     │ #2 重名校验    │    │ testDuplicate│
└──────────┘      └──────────────┘     └────────────────┘    └──────────────┘
```

每个测试都能追溯到需求，每个需求都有测试覆盖。这是 QA 审计的基础。

### 边界用例必测清单

框架在 spec-templates Skill 中定义了边界用例必测清单，Dev/FE 编写测试时必须逐项过一遍：

| # | 类别 | 典型场景 | 示例 |
|---|------|---------|------|
| 1 | Null / 空值 | 入参为 null、空字符串、空数组 | `name = null`、`ids = []` |
| 2 | 边界值 | 最小值、最大值、刚好越界 | `pageSize = 0`、`pageSize = Integer.MAX_VALUE` |
| 3 | 非法类型 / 格式 | 类型不匹配、格式错误 | `id = "abc"`、`email = "not-email"` |
| 4 | 错误路径 | 外部依赖失败、网络超时、数据库异常 | API 返回 500、Redis 连接断开 |
| 5 | 并发 / 竞态 | 同一资源被并发修改 | 两个请求同时删除同一 Agent |
| 6 | 大数据量 | 超大分页、批量操作上限 | 一次导入 10000 条记录 |
| 7 | 特殊字符 | Unicode、SQL 注入字符、XSS payload | `name = "'; DROP TABLE--"` |
| 8 | 权限边界 | 无权限、跨租户访问 | 用户 A 访问用户 B 的资源 |

## 第四层：E2E 测试 — 用户视角的最终验收

### 什么是 E2E 测试

E2E（End-to-End）测试模拟真实用户在浏览器中的操作，验证从点击按钮到看到结果的完整流程。

前三层测试回答的是"代码对不对"，E2E 回答的是"用户能不能用"。

### 技术栈：Playwright

框架的 E2E Agent 基于 [Playwright](https://playwright.dev/) 构建，测试代码存放在 `e2e/tests/{feature-name}/` 目录。

```javascript
// e2e/tests/device-management/create-device.spec.ts
import { test, expect } from '@playwright/test';

test('应该能创建设备并在列表中显示', async ({ page }) => {
  // 导航到设备管理页
  await page.goto('/device/list');

  // 点击新建按钮
  await page.getByRole('button', { name: '新建设备' }).click();

  // 填写表单
  await page.getByLabel('设备名称').fill('测试传感器-001');
  await page.getByLabel('设备类型').selectOption('sensor');
  await page.getByLabel('IP 地址').fill('192.168.1.100');

  // 提交
  await page.getByRole('button', { name: '确定' }).click();

  // 验证列表中出现新设备
  await expect(page.getByText('测试传感器-001')).toBeVisible();
});
```

### E2E 测试故障分类

E2E Agent 将测试失败分为两类，处理方式完全不同：

| 类型 | 原因 | 处理方式 |
|------|------|---------|
| **A 类：E2E 技术问题** | 选择器不匹配、等待超时、Session 注入时机 | E2E Agent **自行修复** |
| **B 类：业务/应用问题** | API 返回非预期、按钮无响应、功能未实现 | **上报主会话**，回到 Dev/FE 修复 |

这个分类很重要：A 类是测试本身的问题，B 类是被测系统的问题。混淆两者会浪费大量调试时间。

### E2E 不是替代，是兜底

E2E 测试**不应该**用来验证业务逻辑的细节——那是单元测试和集成测试的职责。E2E 的定位是验证关键用户流程（登录、CRUD 操作、页面导航）在真实环境中是否通畅。

一个健康的测试金字塔应该是**底层多、顶层少**。如果 E2E 测试比单元测试还多，说明测试策略出了问题。

## 自动化测试矩阵：需求到测试的全链路追溯

### 矩阵示例

框架的测试计划（`04_test_plan.md`）Part A 是一个自动化测试矩阵：

| # | 需求溯源 | 场景描述 | 场景来源 | 测试类型 | 测试代码位置 | 状态 |
|---|---------|---------|---------|---------|-------------|------|
| 1 | 01 §3.2 | 创建设备成功 | 02 Part E | 集成 | `DeviceControllerTest#testCreate` | PASS |
| 2 | 01 §3.2 | 设备名称重复 | 02 Part E | 单元 | `DeviceServiceTest#testDuplicateName` | PASS |
| 3 | 01 §3.2 | 设备名称为空 | 边界清单 #1 | 单元 | `DeviceServiceTest#testNullName` | PASS |
| 4 | 01 §3.2 | 创建设备 XSS | 边界清单 #7 | 单元 | `DeviceServiceTest#testXssName` | PASS |
| 5 | 01 §3.2 | 创建设备全流程 | 02 Part E | E2E | `e2e/tests/device/create.spec.ts` | PASS |

矩阵的每一行都能从**需求 → 场景 → 测试类型 → 测试代码**完整追溯。

### Dev Agent 的 Self-Test 检查项

Dev Agent 在流转 QA 前，必须完成两阶段自查。与测试相关的检查项：

**合规检查（我做的和 Spec 一致吗？）**：
- [ ] 没有实现 Spec 之外的额外功能（YAGNI）

**质量检查（代码本身过关吗？）**：
- [ ] `mvn test` 所有单元测试通过（不允许 `-DskipTests`）
- [ ] 每个新增 Service 方法至少有一个对应测试
- [ ] 每个新增 Controller 端点至少有一个集成测试
- [ ] 02 Part E 的每个场景在测试代码中都有对应 test case

## 经验教训

### 测试金字塔的黄金比例

```
单元测试  70%  ┃████████████████████████████████████
集成测试  20%  ┃████████████
E2E 测试  10%  ┃████████
```

- **单元测试**是地基，覆盖所有业务分支和边界场景，运行快、定位准
- **集成测试**验证组件间的"胶水"是否粘牢，数量不需要太多但每个都要验证关键链路
- **E2E 测试**只覆盖关键用户流程，每个"用户故事"一到两个场景

### 常见反模式

框架的 QA Agent 专门检查的几种反模式：

**1. 测实现不测行为**：

```java
// 反模式：测试调用了哪个 private 方法、用了什么数据结构
@Test
void should_use_hashmap_internally() { ... }  // 不要这样

// 正确：测试输入和输出的关系
@Test
void should_return_discount_for_vip_user() { ... }
```

**2. 断言过弱**：

```java
// 反模式：只断言"不抛异常"
assertDoesNotThrow(() -> service.create(order));

// 正确：断言具体的业务结果
assertEquals(201, response.getStatus());
assertNotNull(response.getOrderId());
```

**3. 测试间共享状态**：

```java
// 反模式：测试 A 创建的数据，测试 B 依赖它
@Test void testA() { repository.save(new Order("ORD-001")); }

@Test void testB() { assertNotNull(repository.find("ORD-001")); }

// 正确：每个测试独立准备数据
@BeforeEach
void setUp() { repository.deleteAll(); }
```

### 给团队的建议

1. **信任 Dev Agent 的 TDD 节奏**：让 Agent 先写测试、再写实现，比你手动补测试效率高得多
2. **边界用例清单是检查清单，不是负担**：逐项过一遍，涉及的写测试，不涉及的注明原因
3. **E2E 测试宁缺毋滥**：只测关键流程，细节交给单元测试
4. **QA 审计是你的朋友**：QA Agent 发现的问题越早修复成本越低
5. **看 04_test_plan.md 的矩阵**：如果矩阵里有很多空行，说明测试覆盖有缺口

---

> **关键记忆点**：测试金字塔的核心不是"写多少测试"，而是"每一层测什么、不测什么"。单元测试管逻辑，集成测试管链路，E2E 管流程。各司其职，不重复不遗漏。
