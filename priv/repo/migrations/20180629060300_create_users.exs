defmodule SlackProxy.Repo.Migrations.CreateUsers do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :name, :string
      add :username, :string, null: false
      add :is_admin, :boolean, default: false

      timestamps(type: :utc_datetime)
    end

    create unique_index(:users, [:username])
  end
end
