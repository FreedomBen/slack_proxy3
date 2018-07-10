defmodule SlackProxy.Repo.Migrations.BuildProxiesAddDisabledAbbrev do
  use Ecto.Migration

  def change do
    alter table(:build_proxies) do
      add :disabled, :boolean, default: false, null: false
      add :abbreviate, :boolean, default: false, null: false
    end
  end
end
