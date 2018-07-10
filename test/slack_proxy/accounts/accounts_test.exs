defmodule SlackProxy.AccountsTest do
  use SlackProxy.DataCase

  alias SlackProxy.Accounts

  describe "credentials" do
    alias SlackProxy.Accounts.Credential

    @valid_attrs %{email: "some@email.com", password: "some password"}
    @update_attrs %{email: "some.updated@email.com", password: "some updated"}
    @invalid_attrs %{email: nil, password_hash: nil}

    def credential_fixture(attrs \\ %{}) do
      {:ok, credential} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Accounts.create_credential()

      credential
    end

    def remove_pass(cred), do: %{cred | password: nil}

    def creds_match(cred1, cred2) do
      assert cred1.email == cred2.email
    end

    test "list_credentials/0 returns all credentials" do
      credential = credential_fixture()
      assert creds_match(Enum.at(Accounts.list_credentials(), 0), credential)
    end

    test "get_credential!/1 returns the credential with given id" do
      credential = credential_fixture()
      assert creds_match(Accounts.get_credential!(credential.id), credential)
    end

    test "create_credential/1 with valid data creates a credential" do
      assert {:ok, %Credential{} = credential} = Accounts.create_credential(@valid_attrs)
      assert credential.email == "some@email.com"
      assert credential.password_hash =~ ~r/.{60,62}/
    end

    test "create_credential/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Accounts.create_credential(@invalid_attrs)
    end

    test "update_credential/2 with valid data updates the credential" do
      credfix = credential_fixture()
      assert {:ok, credential} = Accounts.update_credential(credfix, @update_attrs)
      assert %Credential{} = credential
      assert credential.email == "some.updated@email.com"
      assert credential.password_hash != credfix.password_hash
    end

    test "update_credential/2 with invalid data returns error changeset" do
      credential = credential_fixture()
      assert {:error, %Ecto.Changeset{}} = Accounts.update_credential(credential, @invalid_attrs)
      assert creds_match(credential, Accounts.get_credential!(credential.id))
    end

    test "delete_credential/1 deletes the credential" do
      credential = credential_fixture()
      assert {:ok, %Credential{}} = Accounts.delete_credential(credential)
      assert_raise Ecto.NoResultsError, fn -> Accounts.get_credential!(credential.id) end
    end

    test "change_credential/1 returns a credential changeset" do
      credential = credential_fixture()
      assert %Ecto.Changeset{} = Accounts.change_credential(credential)
    end
  end
end
