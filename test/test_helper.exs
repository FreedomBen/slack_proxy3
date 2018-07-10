# Disable timeouts.  Can be done temporarily with mix test --trace:
#   See: https://stackoverflow.com/a/31321383/2062384
#ExUnit.configure(timeout: :infinity)
ExUnit.start()

Ecto.Adapters.SQL.Sandbox.mode(SlackProxy.Repo, :manual)

