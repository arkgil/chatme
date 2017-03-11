use Mix.Config

config :logger, :console,
  metadata: [:tag]

config :logger,
  level: :info
