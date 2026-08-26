# Event Scheduler Type 文档

本文说明 当前支持的事件类型和 `when` 计算规则。

## 1. 公共字段

- `name`: 事件名（必填）
- `type`: 事件类型（`custom` / `day` / `day2` / `dynamic`，兼容 `list` / `daily`）
- `duration`: 可选；为空时先读 `events.list.json` 同名事件 `duration`，再默认 `9999999`
- `when`: 可选；偏差值（数字或数组）
- `when2`: 可选；真实时间戳（秒/毫秒/可解析时间字符串），会换算为 `when2 - base_time`

## 2. type = custom

`when` 回退顺序：

1. 配置 `when`
2. 配置 `when2`
3. `base_time`

注意：`custom` 不读取 `events.list.when`。

## 3. type = list（兼容旧配置）

内部会映射到 `custom` 处理，但保留一条专用回退：

1. 配置 `when`
2. 配置 `when2`
3. `events.list.json` 同名事件 `when`
4. `base_time`

## 4. type = day

`when` 回退顺序：

1. 配置 `when`
2. 配置 `when2`
3. 当天 `00:00:00`（本地时区）Unix 秒时间戳

不会读取 `events.list.when`。

## 5. type = day2

`when` 回退顺序：

1. 配置 `when`
2. 配置 `when2`
3. 如果配置了 `day`（正整数）：
  从今天开始生成 `day` 天的 `when`（每天 +86400，且都减去 `base_time`）
  可选再加起始偏移天数：`offset`（兼容 `offsetDay` / `offsetDays`），默认 `0`
4. 否则使用默认值：第二天 `00:00:00` 相对 `base_time` 的偏移（`day2Start - base_time`）

不会读取 `events.list.when`。

示例：

```json
{
  "name": "example_multi_day",
  "type": "day2",
  "day": 2,
  "offset": 1
}
```

上例会生成“明天 + 后天”两天。

## 6. type = dynamic

基于 `server_time` 动态生成 `when`（滑动窗口），不走 `events.list.when` 回退。

- `count` 默认 `16`
- `stepSec` 默认 `60`
- `lagSec` 默认 `0`
- `phaseSec` 默认 `0`
- `startOffsetSec` 默认 `0`

```text
anchorAbs = server_time - lagSec
startAbs = floor((anchorAbs - phaseSec) / stepSec) * stepSec + phaseSec + startOffsetSec
when[i] = startAbs + i * stepSec - base_time   (i = 0..count-1)
```

## 7. 兼容映射

- `list` -> `custom`（仅 `list` 保留 `events.list.when` 回退）
- `daily` -> `day`

不支持的类型会被跳过并记录日志。
