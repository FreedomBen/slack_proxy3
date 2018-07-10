defmodule SlackProxyWeb.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias SlackProxy.Accounts
  alias SlackProxyWeb.Router.Helpers, as: Routes

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)
    user = user_id && Accounts.get_user(user_id)
    assign(conn, :current_user, user)
  end

  def login(conn, user) do
    conn
    |> assign(:current_user, user)
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
  end

  def logout(conn) do
    configure_session(conn, drop: true)
  end

  def login_by_email_and_pass(conn, email, given_pass) do
    case Accounts.authenticate_by_email_and_pass(email, given_pass) do
      {:ok, user}             -> {:ok, login(conn, user)}
      {:error, :unauthorized} -> {:error, :unauthorized, conn}
      {:error, :not_found}    -> {:error, :not_found, conn}
    end
  end

  def authenticate_user(conn, _opts) do
    if conn.assigns.current_user do
      conn
    else
      conn
      |> put_flash(:error, "You must be logged in to access that page")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def restrict_to_admin_ui(conn, _opts) do
    if conn.assigns.current_user.is_admin do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to perform this action")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def restrict_to_admin_ui_or_self(conn, _opts) do
    if conn.assigns.current_user.is_admin || conn.assigns.current_user.id == String.to_integer(conn.params["id"]) do
      conn
    else
      conn
      |> put_flash(:error, "You must be an admin to perform this action")
      |> redirect(to: Routes.page_path(conn, :index))
      |> halt()
    end
  end

  def restrict_to_admin_api(conn, _opts) do
    if conn.assigns.current_user.is_admin do
      conn
    else
      conn
      |> put_status(403)
      |> halt()
    end
  end
end
