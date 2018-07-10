defmodule SlackProxyWeb.Router do
  use SlackProxyWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug SlackProxyWeb.Auth   # puts current_user in assigns. access control is handled by controllers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SlackProxyWeb do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
    resources "/users", UserController, only: [:index, :show, :new, :create, :edit, :update]
    resources "/sessions", SessionController, only: [:new, :create, :delete]
    resources "/build_proxies", BuildProxyController
  end

  scope "/", SlackProxyWeb do
    pipe_through :api

    post "/build_proxies/:id/buildcomplete", BuildProxyController, :build_complete
    post "/build_proxies/:id/deploycomplete", BuildProxyController, :deploy_complete
  end
end
