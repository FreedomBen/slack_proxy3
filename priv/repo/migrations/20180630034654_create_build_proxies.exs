defmodule SlackProxy.Repo.Migrations.CreateBuildProxies do
  use Ecto.Migration

  def change do
    create table(:build_proxies) do
      add :avatar, :string
      add :channel, :string, null: false
      add :username, :string
      add :api_token, :string
      add :service_base_url, :string, null: false

      timestamps(type: :utc_datetime)
    end

  end
end
