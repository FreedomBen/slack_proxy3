use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :slack_proxy, SlackProxyWeb.Endpoint,
  http: [port: 4001],
  server: false

# Print only warnings and errors during test
config :logger, level: :warn

# Configure your database
config :slack_proxy, SlackProxy.Repo,
  adapter: Ecto.Adapters.Postgres,
  username: "postgres",
  password: "password",
  database: "slack_proxy3_test",
  hostname: "localhost",
  pool: Ecto.Adapters.SQL.Sandbox
