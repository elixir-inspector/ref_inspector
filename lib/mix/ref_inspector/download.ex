defmodule Mix.RefInspector.Download do
  @moduledoc """
  Utility module to support download tasks.
  """

  @doc """
  Reads a database file from its remote location.
  """
  @spec read_remote(String.t) :: { :ok, term } | { :error, term }
  def read_remote(path) do
    { :ok, _ } = Application.ensure_all_started(:hackney)

    http_opts             = Application.get_env(:ref_inspector, :http_opts, [])
    { :ok, _, _, client } = :hackney.get(path, [], [], http_opts)

    :hackney.body(client)
  end
end
