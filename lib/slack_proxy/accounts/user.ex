defmodule SlackProxy.Accounts.User do
  use Ecto.Schema
  import Ecto.Changeset

  alias SlackProxy.Accounts.Credential

  schema "users" do
    field :name, :string
    field :username, :string
    field :is_admin, :boolean, default: false
    has_one :credential, Credential

    timestamps(type: :utc_datetime)
  end

  def registration_changeset(user, params) do
    user
    |> changeset(params)
    |> cast_assoc(:credential, with: &Credential.changeset/2, required: true)
  end

  def changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username, :is_admin])
    |> validate_changeset(attrs)
  end

  def non_admin_changeset(user, attrs) do
    user
    |> cast(attrs, [:name, :username])
    |> validate_changeset(attrs)
  end

  defp validate_changeset(changeset, attrs) do
    changeset
    |> validate_required([:name, :username])
    |> validate_length(:username, min: 1, max: 20)
    |> unique_constraint(:username)
  end
end
