defmodule SlackProxy.Accounts.Credential do
  use Ecto.Schema
  import Ecto.Changeset

  schema "credentials" do
    field :email, :string
    field :password, :string, virtual: true
    field :password_hash, :string
    belongs_to :user, SlackProxy.Accounts.User

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(credential, attrs) do
    credential
    |> cast(attrs, [:email, :password])
    |> validate_required([:email, :password])
    |> unique_constraint(:email)
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  def password_changeset(credential, %{"password" => ""} = attrs) do
    cast(credential, attrs, [])  # No op cause password is missing from attrs
  end

  def password_changeset(credential, %{"password" => _password} = attrs) do
    credential
    |> cast(attrs, [:password])
    |> validate_required([:password])
    |> validate_length(:password, min: 6, max: 100)
    |> put_pass_hash()
  end

  def password_changeset(credential, attrs) do
    cast(credential, attrs, [])  # No op cause password is missing from attrs
  end

  defp put_pass_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: pass}} ->
        put_change(changeset, :password_hash, Comeonin.Bcrypt.hashpwsalt(pass))

      _ ->
        changeset
    end
  end
end
