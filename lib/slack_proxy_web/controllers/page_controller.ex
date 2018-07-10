defmodule SlackProxyWeb.PageController do
  use SlackProxyWeb, :controller

  def index(conn, _params) do
    if conn.assigns.current_user do
      redirect(conn, to: Routes.build_proxy_path(conn, :index))
    else
      render conn, "index.html"
    end
  end
end
