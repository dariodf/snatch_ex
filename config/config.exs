import Config

#########################

config :logger, level: :info

config :telegex, caller_adapter: Finch

# import_config "#{config_env()}.exs"
