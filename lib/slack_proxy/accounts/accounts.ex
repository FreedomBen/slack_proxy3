defmodule SlackProxy.Accounts do
  import Ecto.Query

  alias SlackProxy.Accounts.Credential
  alias SlackProxy.Accounts.User
  alias SlackProxy.Repo

  def list_users do
    Repo.all(User)
    |> Enum.map(fn u -> Repo.preload(u, :credential) end)
  end

  def get_user(id) do
    Repo.get(User, id)
    |> Repo.preload(:credential)
  end

  def get_user!(id) do
    Repo.get!(User, id)
    |> Repo.preload(:credential)
  end

  def get_user_by(params) do
    Repo.get_by(User, params)
    |> Repo.preload(:credential)
  end

  # Get a changeset based on the user but with no changes yet
  def change_user(%User{} = user) do
    User.changeset(user, %{})
  end

  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def update_user(%User{} = user, %{"credential" => credential} = attrs, opts) do
    case update_user_credential(user, credential) do
      {:ok, _cred} ->
        update_user(user, Map.delete(attrs, "credential"), opts)

      {:error, _changeset} = err ->
        err
    end
  end

  def update_user(%User{} = user, attrs, is_self: is_self) do
    update_user(user, attrs, is_self: is_self, is_admin: user.is_admin)
  end

  def update_user(%User{} = user, attrs, is_self: _, is_admin: true) do
    user
    |> User.changeset(attrs)
    |> Repo.update()
  end

  def update_user(%User{} = user, attrs, is_self: true, is_admin: false) do
    # User must be self, and has a more limited changeset
    user
    |> User.non_admin_changeset(attrs)
    |> Repo.update()
  end

  def update_user_credential(%User{} = user, credential_attrs) do
    Repo.preload(user, :credential).credential
    |> Credential.password_changeset(credential_attrs)
    |> Repo.update()
  end

  # Not intended for programmatic use.  Intended for iex sessions
  def set_admin(user_id, is_admin) do
    Repo.get!(User, user_id)
    |> User.changeset(%{is_admin: is_admin})
    |> Repo.update!()
  end

  alias SlackProxy.Accounts.Credential

  @doc """
  Returns the list of credentials.

  ## Examples

      iex> list_credentials()
      [%Credential{}, ...]

  """
  def list_credentials do
    Repo.all(Credential)
  end

  @doc """
  Gets a single credential.

  Raises `Ecto.NoResultsError` if the Credential does not exist.

  ## Examples

      iex> get_credential!(123)
      %Credential{}

      iex> get_credential!(456)
      ** (Ecto.NoResultsError)

  """
  def get_credential!(id), do: Repo.get!(Credential, id)

  @doc """
  Creates a credential.

  ## Examples

      iex> create_credential(%{field: value})
      {:ok, %Credential{}}

      iex> create_credential(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_credential(attrs \\ %{}) do
    %Credential{}
    |> Credential.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a credential.

  ## Examples

      iex> update_credential(credential, %{field: new_value})
      {:ok, %Credential{}}

      iex> update_credential(credential, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_credential(%Credential{} = credential, attrs) do
    credential
    |> Credential.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a Credential.

  ## Examples

      iex> delete_credential(credential)
      {:ok, %Credential{}}

      iex> delete_credential(credential)
      {:error, %Ecto.Changeset{}}

  """
  def delete_credential(%Credential{} = credential) do
    Repo.delete(credential)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking credential changes.

  ## Examples

      iex> change_credential(credential)
      %Ecto.Changeset{source: %Credential{}}

  """
  def change_credential(%Credential{} = credential) do
    Credential.changeset(credential, %{})
  end

  def register_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs)
    |> Repo.insert()
  end

  def get_user_by_email(email) do
    from(u in User, join: c in assoc(u, :credential), where: c.email == ^email)
    |> Repo.one()
    |> Repo.preload(:credential)
  end

  def authenticate_by_email_and_pass(email, given_pass) do
    user = get_user_by_email(email)

    cond do
      user && Comeonin.Bcrypt.checkpw(given_pass, user.credential.password_hash) ->
        {:ok, user}

      user ->
        {:error, :unauthorized}

      true ->
        Comeonin.Bcrypt.dummy_checkpw()
        {:error, :not_found}
    end
  end
end
