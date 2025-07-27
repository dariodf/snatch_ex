import Config

config :telegex, token: System.fetch_env!("BOT_TOKEN")

config :logger, LoggerTelegramBackend,
  chat_id: System.fetch_env!("CONFIG_CHAT_ID"),
  token: System.fetch_env!("BOT_TOKEN"),
  level: :warning
