defmodule SlackProxyWeb.BuildProxyControllerTest do
  use SlackProxyWeb.ConnCase

  ####
  # TODO:
  #
  # Many of these tests will pass, but when the user is not logged in they are redirected.
  # 
  # 1. Test setup to log in first needs to be done.
  # 2. Also need to add a test for the redirect behavior
  #
  ####
  alias SlackProxy.Proxies

  @create_attrs %{abbreviate: true, api_token: "ABCDEFMjgwZjM2NGEtMDMwNi00ZmEwL", avatar: ":git:", channel: "#wazoo", disabled: false, service_base_url: "https://canopy.githost.io/efile-service", username: "some username"}
  @update_attrs %{abbreviate: false, api_token: "EKRJLERKJLKEJRGEtMDMwNi00ZmEwLT", avatar: ":updated:", channel: "#updated", disabled: false, service_base_url: "https://canopy.githost.io/updated", username: "some updated username"}
  @invalid_attrs %{abbreviate: nil, api_token: "too short", avatar: "no colons", channel: "no octothorpe", disabled: nil, service_base_url: "Not a url", username: nil}

  def fixture(:build_proxy) do
    {:ok, build_proxy} = Proxies.create_build_proxy(@create_attrs)
    build_proxy
  end

  describe "index" do
    @tag :skip
    test "lists all build_proxies", %{conn: conn} do
      conn = get conn, build_proxy_path(conn, :index)
      assert html_response(conn, 200) =~ "Listing Build proxies"
    end
  end

  describe "new build_proxy" do
    test "renders form", %{conn: conn} do
      conn = get conn, build_proxy_path(conn, :new)
      assert html_response(conn, 200) =~ "New Build proxy"
    end
  end

  describe "create build_proxy" do
    @tag :skip
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post conn, build_proxy_path(conn, :create), build_proxy: @create_attrs

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == build_proxy_path(conn, :show, id)

      conn = get conn, build_proxy_path(conn, :show, id)
      assert html_response(conn, 200) =~ "Show Build proxy"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn} do
      conn = post conn, build_proxy_path(conn, :create), build_proxy: @invalid_attrs
      assert html_response(conn, 200) =~ "New Build proxy"
    end
  end

  describe "edit build_proxy" do
    setup [:create_build_proxy]

    test "renders form for editing chosen build_proxy", %{conn: conn, build_proxy: build_proxy} do
      conn = get conn, build_proxy_path(conn, :edit, build_proxy)
      assert html_response(conn, 200) =~ "Edit Build proxy"
    end
  end

  describe "update build_proxy" do
    setup [:create_build_proxy]

    @tag :skip
    test "redirects when data is valid", %{conn: conn, build_proxy: build_proxy} do
      conn = put conn, build_proxy_path(conn, :update, build_proxy), build_proxy: @update_attrs
      assert redirected_to(conn) == build_proxy_path(conn, :show, build_proxy)

      conn = get conn, build_proxy_path(conn, :show, build_proxy)
      assert html_response(conn, 200) =~ "some updated api_token"
    end

    @tag :skip
    test "renders errors when data is invalid", %{conn: conn, build_proxy: build_proxy} do
      conn = put conn, build_proxy_path(conn, :update, build_proxy), build_proxy: @invalid_attrs
      assert html_response(conn, 200) =~ "Edit Build proxy"
    end
  end

  describe "delete build_proxy" do
    setup [:create_build_proxy]

    @tag :skip
    test "deletes chosen build_proxy", %{conn: conn, build_proxy: build_proxy} do
      conn = delete conn, build_proxy_path(conn, :delete, build_proxy)
      assert redirected_to(conn) == build_proxy_path(conn, :index)
      assert_error_sent 404, fn ->
        get conn, build_proxy_path(conn, :show, build_proxy)
      end
    end
  end

  defp create_build_proxy(_) do
    build_proxy = fixture(:build_proxy)
    unless build_proxy do
      require IEx; IEx.pry
    end
    {:ok, build_proxy: build_proxy}
  end
end
