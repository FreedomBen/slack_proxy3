defmodule SlackProxyWeb.BuildProxyView do
  use SlackProxyWeb, :view
  alias SlackProxyWeb.BuildProxyView

  def shorten(string, length) do
    if String.length(string) > length do
      "#{String.slice(string, 0, length)}..."
    else
      string
    end
  end

  def render("index.json", %{build_proxies: build_proxies}) do
    %{data: render_many(build_proxies, BuildProxyView, "build_proxy.json")}
  end

  def render("show.json", %{build_proxy: build_proxy}) do
    %{data: render_one(build_proxy, BuildProxyView, "build_proxy.json")}
  end

  def render("build_proxy.json", %{build_proxy: build_proxy}) do
    %{id: build_proxy.id,
      avatar: build_proxy.avatar,
      channel: build_proxy.channel,
      username: build_proxy.username,
      service_base_url: build_proxy.service_base_url}
  end
end
