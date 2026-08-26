# 内容审核(违禁词检测)系统

## 配置说明 (config.yml)

在 `config/config.yml` 中添加以下配置：

```yaml
# 内容审核配置
contentModeration:
  enabled: true                 # 是否启用内容审核
  blockMode: "direct"           # 拦截模式:
                                #   direct: 直接拦截，返回 { result: "invalid" }
                                #   replace: 替换为星号后发送
  replacementChar: "*"          # 替换字符
  logViolations: true           # 是否记录违规日志
```

### 模式说明

| 模式 | 行为 |
|------|------|
| `direct` | 检测到违规消息直接拦截，返回 `{ result: "invalid" }`，客户端显示"你的言论涉及敏感词" |
| `replace` | 检测到违规消息时将违禁词替换为星号，然后正常发送 |
| `enabled: false` | 完全禁用内容审核，所有消息正常发送 |


### 配置说明

#### settings (全局设置)

| 字段 | 类型 | 默认 | 说明 |
|------|------|------|------|
| enabled | boolean | true | 是否启用检测 |
| checkLevel | string | strict | 检测级别 |
| logViolations | boolean | true | 是否记录违规日志 |
| caseSensitive | boolean | false | 是否区分大小写 |
| cacheResults | boolean | true | 是否启用缓存 |
| cacheTTL | number | 300 | 缓存 TTL(秒) |

#### categories (分类配置)

| 字段 | 类型 | 说明 |
|------|------|------|
| name | string | 分类名称 |
| level | string | 级别: low/medium/high/critical |
| action | string | 动作: block/review/warn |
| autoSubmit | boolean | 是否自动提交审核 |

#### words (违禁词列表)

| 字段 | 类型 | 说明 |
|------|------|------|
| word | string | 主词汇 |
| aliases | string[] | 同义词/变体 |
| type | string | exact/regex |
| pattern | string | 正则模式(type=regex时) |
| description | string | 描述信息 |

## 扩展指南

### 1. 添加新的分类

在 `blocked_words.json` 的 `categories` 中添加：

```json
"new_category": {
  "name": "新分类",
  "level": "medium",
  "action": "review",
  "autoSubmit": false
}
```

### 2. 添加新词汇

在对应分类的 `words` 中添加：

```json
{
  "word": "新词汇",
  "aliases": ["变体1", "变体2"],
  "type": "exact",
  "description": "说明"
}
```

### 3. 添加正则检测

```json
{
  "pattern": "\\d{10,}",
  "type": "regex",
  "description": "10位以上数字"
}
```

### 4. 白名单配置

```json
"whitelist": [
  {
    "pattern": "安全词汇",
    "description": "说明"
  }
]
```
