# 事件系统（Event System）

---

## 1. 运行原理（数据流）

```
data/events/events.yaml
      │  (js-yaml 读入 + 缓存)
      ▼
eventEngine/loader.js  ──read()──►  EventEngine
      │                                 │ 1. 校验(validator)
      │                                 │ 2. 按 serverTime 计算当天零点(dayStart, 时区感知)
      │                                 │ 3. 遍历 collections：
      │                                 │      selectResolvers 选出要下发的事件
      │                                 │      whenResolvers 计算每个事件的 when[]
      ▼                                 ▼
@helper/eventScheduler.getEventSchedule() ──► GetEventSchedule 控制器 ──► 客户端
```

- 引擎是单例，带两级缓存：配置文档不变则复用编译结果；`(编译结果, serverTime)` 不变则复用整份 schedule。
- `serverTime` 默认取 `Date.now()`，可传入用于预览/回归。
- 每次请求输出一份扁平事件表，**客户端看不到 collection/select 等内部结构**。

---

## 2. 目录与模块职责

| 文件 | 职责 |
|---|---|
| `data/events/events.yaml` | **唯一配置源**（活动、任务、采集等） |
---

## 3. 顶层配置（events.yaml 根字段）

```yaml
version: 3                 # 必须为 3
baseTime: 1587366000       # 时间原点；输出的 when 都是"相对 baseTime 的偏移秒"
timezone: Asia/Shanghai    # 所有 daily/times/ISO 解析用的时区（中国无夏令时）
validWindowSec: 1800       # 本次结果的有效期（写入 valid_until）
defaults:                  # 全局默认（可被 collection / event 覆盖）
  duration: 9999999
anchors:                   # 命名基准时间点，供 relative/anchor 引用（见 §6.5）
  season_ap29: "2026-01-16T16:00:00"
collections: [ ... ]       # 集合数组，见下
```

## 4. collection（集合）字段

集合是"组织单元 + 随机/轮换的选择范围"。客户端看不到它。

```yaml
- id: realm_daily_quests        # 必填，唯一
  title: Realm Daily Quests     # 备注用
  enabled: true                 # false 则整组跳过
  active: { startsAt: "...", endsAt: "..." }   # 可选：集合生效窗口（ISO 或 epoch）
  select: { mode: all }         # 选择策略，见 §8
  defaults: { duration: 1d, when: { daily: "00:00" } }  # 可选：本组事件默认
  events: [ ... ]               # 事件数组，见下
```

## 5. event（事件）字段

```yaml
- id: quest_ap31_fetch_01   # 必填，全局唯一；就是下发给客户端的 name
  enabled: true             # 可选，false 跳过
  at: "2026-08-15T00:00"    # when（5 选 1，见 §6）——也可写成 when: { ... }
  duration: forever         # 见 §7；缺省则回退 collection→doc 默认
  # 嵌套（仅 random 集合用）：
  select: { mode: random, count: 1 }
  children: [ { id: ..., daily: "00:00", duration: 1d } ]
```

事件的 `when` 可用**行内简写**（`at` / `daily` / `times` / `window` / `relativeTo`），
也可显式写 `when: { kind: ..., ... }`。行内简写最简洁，推荐。

---

## 6. `when` 的 5 种类型

所有类型最终产出的都是"相对 `baseTime` 的偏移秒数"数组。

### 6.1 `at` — 绝对时间点（一次性）
```yaml
at: "2026-08-15T00:00:00"                        # 单个
at: ["2026-08-15T00:00", "2026-08-16T00:00"]     # 多个
```
字符串按 `timezone` 解析；也支持带 `Z`/`+08:00` 的 ISO。取代旧的 `list`/`absolute`/`offset`。

### 6.2 `daily` — 每天（可连续 N 天）
```yaml
daily: "00:00"          # 每天该时刻
offsetDays: 0           # 从今天+N 天开始（默认 0）
days: 1                 # 连续几天各出一个 when（默认 1）
```
`days: 1` = 旧 `dayStart`；`days: N` = 旧 `dayRange`。时间点 = 当天零点(时区) + offsetDays·天 + 时钟。

### 6.3 `times` — 每天多个固定时刻（就近取一个）
```yaml
times: ["05:30","08:00","12:00","20:00","00:30"]
prepare: 1800           # 提前量(秒或 "30m")；默认 1800
durationSec: <可选>     # 判定"仍在进行"的时长，默认 = duration·60
```
只吐出"正在进行 或 未来 prepare 窗口内即将开始"的**那一个**时刻；否则不下发。取代旧 `dailyTimes`。

### 6.4 `window` — 滑动窗口（高频轮播）
```yaml
window: { every: 60, count: 16 }   # every 秒或 "2m"；count 个点
# 可选：lag / phase / startOffset（秒）
```
以当前时刻对齐生成 count 个等距时间点。取代旧 `dynamic`。

### 6.5 `relative` / `anchor` — 相对基准或另一个事件
```yaml
# 相对顶层 anchors 里的命名基准（推荐用于赛季）
anchor: season_ap29
offset: 7d                            # 赛季基准 + 7 天
```
```yaml
# 相对另一个事件的最早时间
relativeTo: "quest_ap31_fetch_02"
offset: "7d"
```
取基准（`anchors[name]` 或目标事件最早 when）+ offset。事件依赖含循环保护；`none: true` 表示占位不出时间点。

> 赛季用法：顶层 `anchors: { season_ap29: "2026-01-16T16:00" }`，各任务写 `anchor: season_ap29`
> + `offset: 7d/14d/...`；**整季挪期只改 anchor 一行**。迁移已自动把各赛季转成这种写法。

---

## 7. `duration` 时长

单位是**分钟**（下发给客户端的原始单位）。支持：
```yaml
duration: forever     # = 99999999（永久）
duration: 1d          # 1 天 = 1440
duration: 2h30m       # = 150
duration: 90s         # = 1.5
duration: 1440        # 直接写分钟数
```
缺省回退顺序：`event.duration` → `collection.defaults.duration` → `doc.defaults.duration` → `9999999`。

## 8. `select` 选择策略

写在 collection 上（决定下发哪些顶层事件），也可写在事件上（决定下发哪些 `children`）。

```yaml
select: { mode: all }                    # 默认：全部启用事件
```
```yaml
select:                                   # 每天稳定随机 N 个
  mode: random
  count: 1
  salt: realm_daily_quests                # 随机种子盐
  avoidRepeatDays: 1                      # 尽量不与昨天重复
```
```yaml
select:                                   # 按星期几定数量
  mode: random
  salt: treasure_candle_rotation
  avoidRepeatDays: 1
  countByWeekday: { THU: all, FRI: 3, SAT: 3, SUN: 3, default: 1 }
```
```yaml
select: { mode: rotation, count: 1, periodDays: 1, startsAt: "2026-01-01T00:00" }
```

- `count` 可为数字或 `all`；`countByWeekday` 键用 `SUN..SAT`，`all` 表示全出，`default` 兜底。
- **随机是稳定的**：种子 = `集合id:日期:salt`，同一天全服所有请求结果一致。
- **嵌套**：事件带 `children` + 自己的 `select` 时，父被选中后再在其 children 里按子 select 抽选
  （父层为 `all` 的那天，子层也应显式配 `all`，见 §9 迁移说明）。

---

## 9. 输出契约（客户端如何解读）

```jsonc
{ "event_schedule": {
    "server_time": 1790353819,   // 本次服务器时间(秒)
    "valid_until": 1790355619,   // = server_time + validWindowSec
    "base_time":   1587366000,   // 时间原点
    "events": [
      { "name": "quest_ap31_fetch_01", "duration": 99999999, "when": [180252800] }
    ]
} }
```
- `when` 是**相对 `base_time` 的偏移秒**：真实触发时刻 = `base_time + when`。
- `duration` 单位为**分钟**。
- 客户端只看到 `name/duration/when`，看不到 collection/select。

## 10. 怎么写（配方）

- 加一个固定日期的一次性活动：`- { id: xxx, at: "2026-08-15T00:00", duration: forever }`
- 加一个每日采集：在有 `defaults: { daily }` 的集合里 `- { id: xxx }` 即可。
- 周末连开 2 天：`- { id: xxx, daily: "00:00", days: 2 }`
- 每天多时段就近开：`- { id: xxx, times: [...], prepare: 1800 }`
- 每天随机抽 1 个：把它们放进一个 `select: { mode: random, count: 1 }` 的集合。
