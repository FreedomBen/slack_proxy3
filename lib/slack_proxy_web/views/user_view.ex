defmodule SlackProxyWeb.UserView do
  use SlackProxyWeb, :view

  alias SlackProxy.Accounts

  def first_name(%Accounts.User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
