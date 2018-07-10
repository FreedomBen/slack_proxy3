defmodule SlackProxyWeb.PageControllerTest do
  use SlackProxyWeb.ConnCase

  test "GET /", %{conn: conn} do
    conn = get conn, "/"
    assert html_response(conn, 200) =~ "log in"
  end

  ## TODO: GET / redirects to proxy index when logged in
end
