defmodule SlackProxy.Proxies.BuildProxy do
  use Ecto.Schema
  import Ecto.Changeset

  alias SlackProxy.Proxies.BuildProxy

  schema "build_proxies" do
    field :avatar, :string, null: false
    field :channel, :string, null: false
    field :username, :string, null: false
    field :disabled, :boolean, default: false, null: false
    field :api_token, :string, null: false
    field :abbreviate, :boolean, default: false, null: false
    field :service_base_url, :string, null: false

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(build_proxy, attrs) do
    build_proxy
    |> cast(attrs, [:avatar, :channel, :username, :disabled, :api_token, :abbreviate, :service_base_url])
    |> set_default_avatar()
    |> set_default_channel()
    |> set_default_username()
    |> set_default_service_base_url()
    |> gen_api_token_if_empty()
    |> validate_format(:avatar, ~r{^:[\w_-]+:$}) # has : at beginning and end
    |> validate_format(:channel, ~r{^#[\w_-]+$}) # has # at beginning
    |> validate_format(:service_base_url, ~r{^https://canopy.githost.io/.+})
    |> validate_length(:api_token, min: 25, max: 200)
    |> validate_required([:avatar, :channel, :username, :disabled, :api_token, :abbreviate, :service_base_url])
  end

  defp default_avatar, do: ":gitlab:"
  defp default_channel, do: "#gray"
  defp default_username, do: "Gitlab CI Reporter"
  defp default_service_base_url, do: "https://canopy.githost.io/java/efile-service"

  defp set_default_avatar(%Ecto.Changeset{data: %BuildProxy{avatar: nil}} = changeset),
    do: set_default(changeset, :avatar, default_avatar(), handle_nil: true)

  defp set_default_avatar(changeset),
    do: set_default(changeset, :avatar, default_avatar(), handle_nil: false)

  defp set_default_username(%Ecto.Changeset{data: %BuildProxy{username: nil}} = changeset),
    do: set_default(changeset, :username, default_username(), handle_nil: true)

  defp set_default_username(changeset),
    do: set_default(changeset, :username, default_username(), handle_nil: false)

  defp set_default_channel(%Ecto.Changeset{data: %BuildProxy{channel: nil}} = changeset),
    do: set_default(changeset, :channel, default_channel(), handle_nil: true)

  defp set_default_channel(changeset),
    do: set_default(changeset, :channel, default_channel(), handle_nil: false)

  defp set_default_service_base_url(%Ecto.Changeset{data: %BuildProxy{service_base_url: nil}} = changeset),
    do: set_default(changeset, :service_base_url, default_service_base_url(), handle_nil: true)

  defp set_default_service_base_url(changeset),
    do: set_default(changeset, :service_base_url, default_service_base_url(), handle_nil: false)

  defp gen_api_token_if_empty(%Ecto.Changeset{data: %BuildProxy{api_token: nil}} = changeset),
    do: set_default(changeset, :api_token, gen_api_token(), handle_nil: true)

  defp gen_api_token_if_empty(changeset),
    do: set_default(changeset, :api_token, gen_api_token(), handle_nil: false)

  defp set_default(changeset, key, default, handle_nil: true) do
    case get_change(changeset, key) do
      nil -> put_change(changeset, key, default)
       "" -> put_change(changeset, key, default)
        _ -> changeset
    end
  end

  defp set_default(changeset, key, default, handle_nil: false) do
    case get_change(changeset, key) do
       "" -> put_change(changeset, key, default)
        _ -> changeset
    end
  end

  defp gen_api_token(), do: strong_random_string(80)

  defp strong_random_string(length) do
    :crypto.strong_rand_bytes(length)
    |> Base.url_encode64
    |> binary_part(0, length)
  end
end
