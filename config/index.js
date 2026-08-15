const { loadConfig, getConfig, get } = require('@modules/configmanager/index');

loadConfig();

const config = getConfig();

function validateEnv() {
  if (config.database?.type === 'mysql') {
    const requiredMysqlVars = ['host', 'user', 'password', 'name'];
    const missing = requiredMysqlVars.filter(v => !config.database.mysql?.[v]);

    if (missing.length > 0) {
      throw new Error(
        `MySQL mode requires: database.mysql.${missing.join(', database.mysql.')}` +
        '\nPlease update database.mysql in config.yml'
      );
    }
  }

  if (!config.jwt?.secret) {
    throw new Error(
      'JWT secret is missing.\n' +
      'Please set jwt.secret in config.yml (at least 32 chars).\n' +
      'Generate: node -e "console.log(require(\'crypto\').randomBytes(32).toString(\'hex\'))"'
    );
  }

  if (config.jwt?.secret && config.jwt.secret.length < 32) {
    console.warn('Warning: jwt.secret length is below 32; use a stronger secret.');
  }
}

validateEnv();

module.exports = {
  server: {
    port: get('server.port', 4110),
    host: get('server.host', '0.0.0.0')
  },

  database: {
    type: get('database.type', 'sqlite'),
    path: get('database.sqlite.path', './data/db/sky.db'),

    host: get('database.mysql.host', '127.0.0.1'),
    port: get('database.mysql.port', 3306),
    user: get('database.mysql.user', 'root'),
    password: get('database.mysql.password', ''),
    name: get('database.mysql.name', 'xysky'),

    connectionLimit: get('database.mysql.connectionLimit', 10),
    queueLimit: get('database.mysql.queueLimit', 0),
    idleTimeout: get('database.mysql.idleTimeout', 60000),
    maxIdle: get('database.mysql.maxIdle', 5),
    connectTimeout: get('database.mysql.connectTimeout', 10000),
    waitForConnections: true
  },

  jwt: {
    secret: config.jwt?.secret,
    expiresIn: get('jwt.expiresIn', '7d')
  },

  udp: {
    uri: get('udp.uri', '127.0.0.1:19132')
  },

  cdn: {
    host: get('cdn.host', 'sky.resources.cdn.thatgamecompany.com'),
    prefix: get('cdn.prefix', '')
  },

  mqtt: {
    brokerUrl: get('mqtt.brokerUrl', ''),
    username: get('mqtt.username', ''),
    password: get('mqtt.password', '')
  },

  game: {
    initialCurrency: get('game.initialCurrency', {}),
    socialFeed: {
      socialFeedExpireDays: get('game.socialFeed.socialFeedExpireDays', 30),
      uri: get('game.socialFeed.uri', 'live-as-sky.xyqaq.cn'),
      curatedFeeds: {
        defaultFillPriority: get('game.socialFeed.curatedFeeds.defaultFillPriority', ['friends', 'followed', 'public', 'local']),
        friendsQueryLimit: get('game.socialFeed.curatedFeeds.friendsQueryLimit', 2000),
        followedQueryLimit: get('game.socialFeed.curatedFeeds.followedQueryLimit', 2000),
        publicQueryLimit: get('game.socialFeed.curatedFeeds.publicQueryLimit', 4000),
        localQueryLimit: get('game.socialFeed.curatedFeeds.localQueryLimit', 4000),
        maxBucketCount: get('game.socialFeed.curatedFeeds.maxBucketCount', 200),
        allowCrossRingFill: get('game.socialFeed.curatedFeeds.allowCrossRingFill', true),
        allowCrossBucketFill: get('game.socialFeed.curatedFeeds.allowCrossBucketFill', true),
        defaultInnerRadius: get('game.socialFeed.curatedFeeds.defaultInnerRadius', 16),
        defaultOuterRadius: get('game.socialFeed.curatedFeeds.defaultOuterRadius', 0),
        defaultVerticalRadius: get('game.socialFeed.curatedFeeds.defaultVerticalRadius', 24),
        scoreAlgoVersion: get('game.socialFeed.curatedFeeds.scoreAlgoVersion', 'v1a32'),
        totalAvailableResultsMode: get('game.socialFeed.curatedFeeds.totalAvailableResultsMode', 'filtered_unique'),
        liteFields: get('game.socialFeed.curatedFeeds.liteFields', ['social_feed_id','user_id','author_id','pool_type','pool_name','level_id','create_at','expire_at','message','content_type','content','resource_id','recording_id','tags','reactions','state','comments_enabled','location','local_creation','followed','friend'])
      }
    }
  },

  cache: get('cache', {}),

  contentModeration: {
    enabled: get('contentModeration.enabled', true),
    blockMode: get('contentModeration.blockMode', 'direct'),
    replacementChar: get('contentModeration.replacementChar', '*'),
    logViolations: get('contentModeration.logViolations', true)
  },

  logger: {
    apiregister: get('logger.api_register', false),
    stackerror: get('logger.request_stack_error', true)
  }

};
