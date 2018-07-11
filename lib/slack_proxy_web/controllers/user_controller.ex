defmodule SlackProxyWeb.UserController do
  use SlackProxyWeb, :controller

  alias SlackProxy.Accounts

  plug :authenticate_user when action in [:index, :show]
  plug :restrict_to_admin_ui when action in [:new, :create]
  plug :restrict_to_admin_ui_or_self when action in [:update]

  def index(conn, _params) do
    users = Accounts.list_users()
    render(conn, "index.html", users: users)
  end

  def show(conn, %{"id" => id}) do
    user = Accounts.get_user(id)
    render(conn, "show.html", user: user, shown_user_id: String.to_integer(id))
  end

  def new(conn, _params) do
    changeset = Accounts.change_user(%Accounts.User{})
    # shown_user_id doesn't make sense when creating a user that doesn't exist yet
    render(conn, "new.html", shown_user_id: conn.assigns.current_user.id, changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.register_user(user_params) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "#{user.name} created!")
        |> redirect(to: Routes.user_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    user = Accounts.get_user!(id)
    changeset = Accounts.change_user(user)
    render(conn, "edit.html", user: user, shown_user_id: String.to_integer(id), changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user_params = restrict_password_change_to_owner(conn, id, user_params)
    user = Accounts.get_user(id)

    case Accounts.update_user(user, user_params, updating_user: conn.assigns.current_user) do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: user_path(conn, :show, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, shown_user_id: String.to_integer(id), changeset: changeset)
    end
  end

  defp restrict_password_change_to_owner(conn, id, user_params) do
    # This is just a backend check for integrity.  The control should not be visible
    # on the front end so don't worry about providing a helpful explanation of why
    # the user can't change somebody else's password

    case user_is_updating_self?(conn, id) do
      true -> user_params
         _ -> Map.update!(user_params, "credential", fn(c) -> Map.delete(c, "password") end)
    end
  end

  defp user_is_updating_self?(conn, id), do: String.to_integer(id) == conn.assigns.current_user.id
end
