defmodule SlackProxyWeb.BuildProxyController do
  use SlackProxyWeb, :controller

  alias SlackProxy.Proxies
  alias SlackProxy.Proxies.BuildProxy

  action_fallback SlackProxyWeb.FallbackController

  plug :authenticate_user when action in [:index, :show]
  plug :restrict_to_admin_ui when action in [:create, :update, :delete]

  plug :assign_build_proxy when action in [:build_complete, :deploy_complete]
  plug :validate_token when action in [:build_complete, :deploy_complete]
  plug :halt_if_disabled when action in [:build_complete, :deploy_complete]

  def index(conn, _params) do
    build_proxies = Proxies.list_build_proxies()
    render(conn, "index.html", build_proxies: build_proxies)
  end

  def new(conn, _params) do
    changeset = Proxies.change_build_proxy(%BuildProxy{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"build_proxy" => build_proxy_params}) do
    case Proxies.create_build_proxy(build_proxy_params) do
      {:ok, build_proxy} ->
        conn
        |> put_flash(:info, "Build proxy created successfully.")
        |> redirect(to: build_proxy_path(conn, :show, build_proxy))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    build_proxy = Proxies.get_build_proxy!(id)
    render(conn, "show.html", build_proxy: build_proxy)
  end

  def edit(conn, %{"id" => id}) do
    build_proxy = Proxies.get_build_proxy!(id)
    changeset = Proxies.change_build_proxy(build_proxy)
    render(conn, "edit.html", build_proxy: build_proxy, changeset: changeset)
  end

  def update(conn, %{"id" => id, "build_proxy" => build_proxy_params}) do
    build_proxy = Proxies.get_build_proxy!(id)

    case Proxies.update_build_proxy(build_proxy, build_proxy_params) do
      {:ok, build_proxy} ->
        conn
        |> put_flash(:info, "Build proxy updated successfully.")
        |> redirect(to: build_proxy_path(conn, :show, build_proxy))
      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", build_proxy: build_proxy, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    build_proxy = Proxies.get_build_proxy!(id)
    {:ok, _build_proxy} = Proxies.delete_build_proxy(build_proxy)

    conn
    |> put_flash(:info, "Build proxy deleted successfully.")
    |> redirect(to: build_proxy_path(conn, :index))
  end

  #### Below are the controller for the API

  @slack_base_uri "https://slack.com/api/chat.postMessage"

  def build_complete(conn, %{"id" => id} = params) do
    assign_build_proxy(conn, id)
    |> assign_build_complete_header_text(params)
    |> slack_chat_postmessage(params)
  end

  def deploy_complete(conn, %{"id" => id} = params) do
    assign_build_proxy(conn, id)
    |> assign_deploy_complete_header_text(params)
    |> slack_chat_postmessage(params)
  end

  defp assign_build_complete_header_text(conn, params) do
    assign(conn, :header_text, "Build  #{success_fail_msg(params)} - #{conn.assigns.build_proxy.service_base_url}/merge_requests/#{params["mr_id"]}")
  end

  defp assign_deploy_complete_header_text(conn, params) do
    assign(conn, :header_text, "Deploy to #{params["environment"]} #{success_fail_msg(params)}")
  end

  defp assign_build_proxy(conn, _opts) do
    assign(conn, :build_proxy, Proxies.get_build_proxy!(conn.params["id"]))
  end

  defp halt_if_disabled(conn, _opts) do
    case conn.assigns.build_proxy.disabled do
      true -> 
        conn
        |> halt()
        |> put_status(:created)
        |> json(%{ok: "Request succeeded, but build proxy is currently disabled."})

      _ ->
        conn
    end
  end

  defp validate_token(conn, _opts) do
    case conn.assigns.build_proxy.api_token == conn.params["api_token"] do
      true ->
        conn

      _ -> 
        conn
        |> halt()
        |> put_status(:unauthorized)
        |> json(%{error: "Invalid token"})
    end
  end

  defp slack_chat_postmessage(conn, params) do
    assign_info_block(conn, params)
    |> assign_slack_request_body
    |> post_to_slack
    |> return_json
  end

  defp return_json(conn) do
    conn
    |> put_status(:created)
    |> json(conn.assigns.return_json)
  end

  defp post_to_slack(conn) do
    case HTTPoison.post(
      @slack_base_uri,
      conn.assigns.slack_request_body,
      [{"Content-Type", "application/x-www-form-urlencoded"}]
    ) do
	  {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        assign(conn, :return_json, body)

	  {:error, %HTTPoison.Error{reason: reason}} ->
        assign(conn, :return_json, Map.merge(%{ok: false}, reason))
    end
  end

  defp slack_token do
    Map.fetch!(System.get_env(), "SLACK_TOKEN")
  end

  defp assign_slack_request_body(conn) do
    assign(conn, :slack_request_body, Enum.join([
      "token=#{slack_token()}",
      "channel=#{conn.assigns.build_proxy.channel}",
      "text=#{URI.encode(conn.assigns.info_block)}",
      "username=#{URI.encode(conn.assigns.build_proxy.username)}",
      "icon_emoji=#{conn.assigns.build_proxy.avatar}"
    ], "&"))
  end

  defp assign_info_block(conn, params) do
    case conn.assigns.build_proxy.abbreviate do
      true ->
        assign(conn, :info_block, conn.assigns.header_text)

      _ -> 
        assign(conn, :info_block, """
          #{conn.assigns.header_text}
          ```
          Author:           #{params["author"]}
          Commit title:     #{params["title"]}
          Branch:           #{params["branch"]}
          Started by:       #{params["user"]}
          ```
          """
        )
    end
  end

  defp success_fail_msg(%{"failed" => "true"}), do: ":x:  *Failed!*"
  defp success_fail_msg(_params), do: ":heavy_check_mark:  Succeeded!"
end
