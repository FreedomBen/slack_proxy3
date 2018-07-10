defmodule SlackProxy.Proxies do
  @moduledoc """
  The Proxies context.
  """

  import Ecto.Query, warn: false
  alias SlackProxy.Repo

  alias SlackProxy.Proxies.BuildProxy

  @doc """
  Returns the list of build_proxies.

  ## Examples

      iex> list_build_proxies()
      [%BuildProxy{}, ...]

  """
  def list_build_proxies do
    Repo.all(BuildProxy)
  end

  @doc """
  Gets a single build_proxy.

  Raises `Ecto.NoResultsError` if the Build proxy does not exist.

  ## Examples

      iex> get_build_proxy!(123)
      %BuildProxy{}

      iex> get_build_proxy!(456)
      ** (Ecto.NoResultsError)

  """
  def get_build_proxy!(id), do: Repo.get!(BuildProxy, id)

  @doc """
  Creates a build_proxy.

  ## Examples

      iex> create_build_proxy(%{field: value})
      {:ok, %BuildProxy{}}

      iex> create_build_proxy(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_build_proxy(attrs \\ %{}) do
    %BuildProxy{}
    |> BuildProxy.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a build_proxy.

  ## Examples

      iex> update_build_proxy(build_proxy, %{field: new_value})
      {:ok, %BuildProxy{}}

      iex> update_build_proxy(build_proxy, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_build_proxy(%BuildProxy{} = build_proxy, attrs) do
    build_proxy
    |> BuildProxy.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a BuildProxy.

  ## Examples

      iex> delete_build_proxy(build_proxy)
      {:ok, %BuildProxy{}}

      iex> delete_build_proxy(build_proxy)
      {:error, %Ecto.Changeset{}}

  """
  def delete_build_proxy(%BuildProxy{} = build_proxy) do
    Repo.delete(build_proxy)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking build_proxy changes.

  ## Examples

      iex> change_build_proxy(build_proxy)
      %Ecto.Changeset{source: %BuildProxy{}}

  """
  def change_build_proxy(%BuildProxy{} = build_proxy) do
    BuildProxy.changeset(build_proxy, %{})
  end
end
