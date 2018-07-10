defmodule SlackProxy.ProxiesTest do
  use SlackProxy.DataCase

  alias SlackProxy.Proxies

  describe "build_proxies" do
    alias SlackProxy.Proxies.BuildProxy

    @valid_attrs %{avatar: ":git:", channel: "#wazoo", service_base_url: "https://canopy.githost.io/efile-service", username: "some username", api_token: "ABCDEFMjgwZjM2NGEtMDMwNi00ZmEwL"}
    @update_attrs %{avatar: ":updated:", channel: "#updated", service_base_url: "https://canopy.githost.io/update", username: "some updated username", api_token: "EKRJLERKJLKEJRGEtMDMwNi00ZmEwLT"}
    @invalid_attrs %{avatar: nil, channel: "channel", service_base_url: nil, username: nil, api_token: nil}

    def build_proxy_fixture(attrs \\ %{}) do
      {:ok, build_proxy} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Proxies.create_build_proxy()

      build_proxy
    end

    test "list_build_proxies/0 returns all build_proxies" do
      build_proxy = build_proxy_fixture()
      assert Proxies.list_build_proxies() == [build_proxy]
    end

    test "get_build_proxy!/1 returns the build_proxy with given id" do
      build_proxy = build_proxy_fixture()
      assert Proxies.get_build_proxy!(build_proxy.id) == build_proxy
    end

    test "create_build_proxy/1 with valid data creates a build_proxy" do
      assert {:ok, %BuildProxy{} = build_proxy} = Proxies.create_build_proxy(@valid_attrs)
      assert build_proxy.api_token == "ABCDEFMjgwZjM2NGEtMDMwNi00ZmEwL"
      assert build_proxy.avatar == ":git:"
      assert build_proxy.channel == "#wazoo"
      assert build_proxy.service_base_url == "https://canopy.githost.io/efile-service"
      assert build_proxy.username == "some username"
    end

    test "create_build_proxy/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Proxies.create_build_proxy(@invalid_attrs)
    end

    test "create_build_proxy/1 with invalid avatar" do
      assert {
        :error,
        %Ecto.Changeset{
          changes: %{},
          errors: [avatar: {"has invalid format", [validation: :format]}],
          valid?: false
        }
      } = Proxies.create_build_proxy(Map.put(@valid_attrs, :avatar, "invalid avatar"))
    end

    test "create_build_proxy/1 with invalid channel" do
      assert {
        :error,
        %Ecto.Changeset{
          changes: %{},
          errors: [channel: {"has invalid format", [validation: :format]}]
        }
      } = Proxies.create_build_proxy(Map.put(@valid_attrs, :channel, "invalid channel"))
    end

    test "create_build_proxy/1 with invalid service url" do
      assert {
        :error,
        %Ecto.Changeset{
          changes: %{},
          errors: [service_base_url: {"has invalid format", [validation: :format]}],
          valid?: false
        }
      } = Proxies.create_build_proxy(Map.put(@valid_attrs, :service_base_url, "invalid url"))
    end

    test "create_build_proxy/1 with too short api token" do
      assert {
        :error,
        %Ecto.Changeset{
          changes: %{},
          errors: [api_token: {err_msg, [count: _, validation: :length, min: 25]}],
          valid?: false
        }
      } = Proxies.create_build_proxy(Map.put(@valid_attrs, :api_token, "Too short"))
      assert err_msg =~ ~r{should.be.at.least.*character}
    end

    test "create_build_proxy/1 with no API token causes one to be generated" do
      {:ok, %BuildProxy{api_token: api_token}}
        = Proxies.create_build_proxy(Map.delete(@valid_attrs, :api_token))
      assert api_token =~ ~r/^[\w_-]{80}$/
    end

    test "update_build_proxy/2 with valid data updates the build_proxy" do
      build_proxy = build_proxy_fixture()
      assert {:ok, build_proxy} = Proxies.update_build_proxy(build_proxy, @update_attrs)
      assert %BuildProxy{} = build_proxy
      assert build_proxy.api_token == "EKRJLERKJLKEJRGEtMDMwNi00ZmEwLT"
      assert build_proxy.avatar == ":updated:"
      assert build_proxy.channel == "#updated"
      assert build_proxy.service_base_url == "https://canopy.githost.io/update"
      assert build_proxy.username == "some updated username"
    end

    test "update_build_proxy/2 with invalid data returns error changeset" do
      build_proxy = build_proxy_fixture()
      assert {:error, %Ecto.Changeset{}} = Proxies.update_build_proxy(build_proxy, @invalid_attrs)
      assert build_proxy == Proxies.get_build_proxy!(build_proxy.id)
    end

    test "delete_build_proxy/1 deletes the build_proxy" do
      build_proxy = build_proxy_fixture()
      assert {:ok, %BuildProxy{}} = Proxies.delete_build_proxy(build_proxy)
      assert_raise Ecto.NoResultsError, fn -> Proxies.get_build_proxy!(build_proxy.id) end
    end

    test "change_build_proxy/1 returns a build_proxy changeset" do
      build_proxy = build_proxy_fixture()
      assert %Ecto.Changeset{} = Proxies.change_build_proxy(build_proxy)
    end
  end
end
