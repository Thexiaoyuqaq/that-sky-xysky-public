# 插件开发文档（Plugin API）

XYSky 内置了一套**声明式事件插件系统**
往 `plugins/` 目录放入自己的插件文件，监听玩家聊天、上线、下线等事件，
读取 / 修改数据、拦截请求，或做纯通知（记日志、推送、统计等）。

本文面向**第三方插件作者**，说明插件的目录结构、生命周期、可用 API 和内置事件。

---

## 目录

- [1. 快速上手](#1-快速上手)
- [2. 插件放在哪里](#2-插件放在哪里)
- [3. 插件的形态](#3-插件的形态)
- [4. `plugin.json` 清单（可选）](#4-pluginjson-清单可选)
- [5. `init(api)` 能拿到什么](#5-initapi-能拿到什么)
- [6. 内置事件参考](#6-内置事件参考)
- [7. 事件对象通用能力](#7-事件对象通用能力)
- [8. 插件之间协作（元数据）](#8-插件之间协作元数据)
- [9. 优先级与执行顺序](#9-优先级与执行顺序)
- [10. 完整示例](#10-完整示例)

---

## 1. 快速上手

在 `plugins/` 目录新建一个 `hello.js`：

```js
module.exports = {
  name: 'hello',
  version: '1.0.0',

  init(api) {
    api.logger.info('hello 插件已启用');

    api.on('onPlayerChat', async (event) => {
      api.logger.info(`收到聊天: ${event.getMessage()}`);
    });
  },
};
```

启动服务端，日志出现 `[Plugins] 启用 hello v1.0.0` 即表示加载成功。
每当有玩家发送聊天，就会打印一行日志。

---

## 2. 插件放在哪里

插件目录位于**程序运行根目录**下的 `plugins/`：

- 二进制发行版：与 `xysky.exe` / `xysky-linux-x64` 同级的 `plugins/` 目录。
- 若目录不存在，服务端首次启动会自动创建。

```text
that-sky-xysky-public/
├── xysky.exe               # 或 xysky-linux-x64
├── config/
├── data/
└── plugins/                # ← 你的插件放这里
    ├── chat-filter.js
    ├── connection-logger.js
    └── my-plugin/          # 文件夹形态
        ├── index.js
        └── plugin.json
```

> 以 `.` 或 `_` 开头的文件 / 文件夹会被忽略（方便你放临时文件、私有工具）。

---

## 3. 插件的形态

插件支持两种形态，二选一：

### 单文件插件

直接在 `plugins/` 下放一个 `.js` 文件：

```text
plugins/chat-filter.js
```

### 文件夹插件

适合需要拆分多个文件、携带资源或 `plugin.json` 清单的插件。
**入口必须是文件夹内的 `index.js`**：

```text
plugins/my-plugin/
├── index.js         # 入口（必需）
├── plugin.json      # 清单（可选）
└── lib/             # 你自己的代码 / 资源
```

无论哪种形态，入口模块都必须导出一个对象：

```js
module.exports = {
  name: 'my-plugin',      // 插件名（建议填，见下）
  version: '1.0.0',       // 版本（可选）
  init(api) { /* ... */ },// 必需：注册逻辑的入口
  dispose() { /* ... */ },// 可选：卸载 / 热重载时清理
};
```

- **`init(api)` 是唯一必需的导出**。缺少它的模块会被跳过并告警。
- 没有显式 `name` 时，会依次回退到 `plugin.json` 的 `name`、再到文件名。
- **插件名必须唯一**，重名的插件会被跳过。

---

## 4. `plugin.json` 清单（可选）

文件夹插件可以在同目录放一个 `plugin.json`，用于声明元信息或禁用插件：

```json
{
  "name": "my-plugin",
  "version": "1.2.0",
  "enabled": true,
  "description": "一句话说明",
  "author": "you"
}
```

| 字段 | 说明 |
| --- | --- |
| `name` | 插件名。`index.js` 里 `module.exports.name` 优先级更高。 |
| `version` | 版本号，未指定时默认 `0.0.0`。 |
| `enabled` | 设为 `false` 可在不删文件的情况下禁用该插件。 |
| 其它字段 | 会原样并入 `api.meta`，供插件自行读取。 |

> `module.exports` 里的 `name` / `version` 覆盖 `plugin.json` 的同名字段。

---

## 5. `init(api)` 能拿到什么

服务端为**每个插件**构造一个独立的 `api` 实例并传入 `init(api)`。
通过它注册的监听器都记在该插件名下，热重载 / 卸载时会被精确清理。

| 成员 | 类型 | 说明 |
| --- | --- | --- |
| `api.on(event, handler, opts?)` | 函数 | 注册事件监听器，返回 `api` 支持链式调用。 |
| `api.logger` | 对象 | 带 `[Plugin:<name>]` 前缀的日志器：`info / warn / error / success`。 |
| `api.db` | 对象 | 全部数据库 Repository 集合（见下）。 |
| `api.config` | 对象 | 只读的全局配置（对应 `config/config.yml` 等合并结果）。 |
| `api.pluginDir` | 字符串 | 当前插件所在目录，读取自带资源时用。 |
| `api.pluginName` | 字符串 | 当前插件名。 |
| `api.meta` | 对象 | 插件清单信息（`name` / `version` / `plugin.json` 其它字段）。 |

### `api.on(eventName, handler, options?)`

- `eventName`：必须是**已注册的事件名**（见[内置事件参考](#7-内置事件参考)）。监听未注册的事件会被忽略并告警。
- `handler`：`async (event) => {}`。可读写 `event`、可 `event.cancel()`。
- `options.priority`：数字，**越小越先执行**，默认 `0`。仅对 `sequential` 事件有意义。

### `api.db` 数据库访问

`api.db` 直接暴露服务端的 Repository 集合，例如：

```js
await api.db.chatRepository.insertChatMessage(/* ... */);
const user = await api.db.userRepository.findById(userId);
```

可用的 Repository（部分）：

```text
userRepository        currencyRepository    chatRepository
friendshipRepository  followerRepository    messageRepository
infractionRepository  itemUnlockRepository   questRepository
seasonRepository      socialFeedRepository   recordingRepository
playerDataRepository  playerStatusRepository playerVarRepository ...
```

> Repository 方法签名以实际服务端版本为准。数据库写操作请务必做好参数校验，
> 并考虑失败时不要阻塞主流程（见[最佳实践](#12-最佳实践与注意事项)）。

> Repository是操作数据库的唯一路径方式，目前暂无公开文档，及函数方法，后续会逐步开放，你可以加入群聊来获取响应你需要的api信息：273576833

⚠️ **注意**：`api.db` 直接操作生产数据。请谨慎使用写方法，避免破坏数据一致性。


## 6. 内置事件参考

以下是当前内置的事件。事件由服务端提供，插件只负责 `api.on(...)` 监听。

### `onPlayerChat` — 玩家发送聊天

| 属性 | 值 |
| --- | --- |
| 绑定接口 | `POST /account/chat/send` |
| 模式 | `sequential`（可改数据、可拦截） |

| 方法 | 说明 |
| --- | --- |
| `event.getMessage()` / `setMessage(text)` | 读写聊天内容（回写生效） |
| `event.getChannel()` / `setChannel(ch)` | 读写频道 |
| `event.getLevelId()` / `setLevelId(lvl)` | 读写场景 |
| `event.userId` | 发送者用户 ID |
| `event.cancel({ result: 'invalid', ... })` | 拦截本条消息（不落库、不广播） |

被取消时默认返回 `{ result: 'invalid' }`，可用 `cancel(payload)` 自定义。

### `onPlayerConnect` — 玩家 WebSocket 连接建立

| 属性 | 值 |
| --- | --- |
| 触发点 | WebSocket 连接完成且服务端鉴权通过后 |
| 模式 | `parallel`（纯通知） |

| 方法 | 说明 |
| --- | --- |
| `event.getUuid()` / `event.userId` | 玩家 UUID（即 userId） |
| `event.getConnectionId()` | 本次连接 id |
| `event.getOderId()` | 订单 / 会话标识 |
| `event.getRemoteAddress()` | 客户端 IP |
| `event.getUserAgent()` | 客户端 UA |

### `onPlayerDisconnect` — 玩家 WebSocket 连接断开

| 属性 | 值 |
| --- | --- |
| 触发点 | WebSocket `close` 时 |
| 模式 | `parallel`（纯通知） |

| 方法 | 说明 |
| --- | --- |
| `event.getUuid()` / `event.userId` | 玩家 UUID |
| `event.getConnectionId()` | 断开的连接 id |
| `event.getCode()` / `getReason()` | 关闭码 / 原因 |
| `event.isStillOnline()` | 该用户是否仍有其它连接在线（多端场景） |

> 更多事件会随服务端版本增加。启动日志中 `[Plugins] 注册事件 <name>` 会列出当前可用事件。

---

## 7. 事件对象通用能力

所有事件对象（无论哪种模式）都继承以下能力：

| 成员 | 说明 |
| --- | --- |
| `event.userId` | 归属用户 ID（未鉴权时为 `null`） |
| `event.cancel(response?)` | 取消（仅 `sequential` 有效）。`response` 为取消时返回给客户端的响应体 |
| `event.isCancelled()` | 是否已被取消 |
| `event.setResponse(payload)` / `getResponse()` | 读写将要返回的响应体 |
| `event.setMeta(k, v)` / `getMeta(k, fallback?)` | 事件内元数据读写（见下节） |
| `event.hasMeta(k)` / `mergeMeta(obj)` / `getAllMeta()` | 元数据辅助方法 |

---

## 8. 插件之间协作（元数据）

多个插件监听同一个事件时，不要互相 `require`。
推荐用 **事件元数据** 解耦协作：元数据只在**同一次事件分发**内共享，不会污染 `req` 或响应。

典型的「生产者 → 消费者」模式：

```js
// 插件 A（priority: 0，先跑）——打分
api.on('onPlayerChat', async (event) => {
  const msg = event.getMessage() || '';
  let score = 0;
  if (/(.)\1{4,}/.test(msg)) score += 3;   // 连续重复字符
  if (msg.length > 200) score += 2;         // 刷屏
  event.setMeta('spamScore', score);
  event.setMeta('spamScoredBy', api.pluginName);
}, { priority: 0 });
```

```js
// 插件 B（priority: 20，后跑）——根据分值决策
api.on('onPlayerChat', async (event) => {
  const score = event.getMeta('spamScore', 0);   // 上游没跑就默认 0
  if (score >= 5) {
    event.cancel({ result: 'invalid', reason: 'spam_detected', score });
  }
}, { priority: 20 });
```

即便插件 A 不存在，插件 B 靠 `getMeta('spamScore', 0)` 的默认值也能安全运行。

---

## 9. 优先级与执行顺序

- 仅 `sequential` 事件有顺序概念，按 `priority` **升序**串行执行（`priority` 越小越先）。
- 相同 `priority` 之间的相对顺序不做保证，不要依赖。
- 任一插件 `cancel()` 后，**该优先级之后的插件不再执行**。
- `parallel` 事件全部并发，`priority` 被忽略。

约定俗成的分层（非强制）：

| priority | 用途 |
| --- | --- |
| `0` 左右 | 预处理 / 打分 / 规范化数据 |
| `10` 左右 | 内容过滤 / 替换 |
| `20+` | 最终裁决 / 拦截 |

---

## 10. 完整示例

### 示例 1：聊天内容过滤（sequential，拦截 + 改写）

```js
module.exports = {
  name: 'chat-filter',
  version: '1.0.0',

  init(api) {
    api.logger.info('chat-filter enable');

    api.on('onPlayerChat', async (event) => {
      const msg = event.getMessage() || '';

      // 含链接 → 直接拦截
      if (msg.includes('http://') || msg.includes('https://')) {
        api.logger.warn(`拦截含链接消息: user=${event.userId}`);
        return event.cancel({ result: 'invalid', reason: 'link_not_allowed' });
      }

      // 敏感词 → 替换后放行
      if (msg.includes('笨蛋')) {
        event.setMessage(msg.replace(/笨蛋/g, '**'));
        api.logger.info(`已替换敏感词: user=${event.userId}`);
      }
    }, { priority: 10 });
  },

  dispose() {},
};
```

### 示例 2：连接日志（parallel，纯通知）

```js
module.exports = {
  name: 'connection-logger',
  version: '1.0.0',

  init(api) {
    api.on('onPlayerConnect', async (event) => {
      api.logger.info(
        `玩家上线 uuid=${event.getUuid()} conn=${event.getConnectionId()} ip=${event.getRemoteAddress()}`
      );
    });

    api.on('onPlayerDisconnect', async (event) => {
      api.logger.info(
        `玩家下线 uuid=${event.getUuid()} code=${event.getCode()} 仍在线=${event.isStillOnline()}`
      );
    });
  },
};
```

### 示例 3：反刷屏（元数据协作，生产者 + 消费者）

见[第 9 节](#9-插件之间协作元数据)的 `spam-scorer` / `spam-blocker` 拆分：
一个插件打分写入 `spamScore`，另一个插件读取分值决定是否 `cancel`。

> 以上示例的可运行版本已放在仓库的 `plugins/` 目录中，可直接参考。

