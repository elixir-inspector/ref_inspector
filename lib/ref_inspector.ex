defmodule RefInspector do
  @moduledoc """
  Referer parser library.

  ## Usage

      iex> RefInspector.parse("http://www.google.com/search?q=ref_inspector")
      %RefInspector.Result{
        referer: "http://www.google.com/search?q=ref_inspector",
        medium: :search,
        source: "google",
        term: "ref_inspector"
      }

  Passing a referer string will result in a `%RefInspector.Result{}` returned
  with the following information (if available):

  - `:referer` will contain the unmodified referer passed to the parser.

  - `:medium` will be one of `:unknown`, `:email`, `:paid`, `:search`, `:social`
    or `:internal`. The detection as an internal referer requires additional
    configuration.

  - `:source` will be `:unknown` if no known source could be detected.
    Otherwise it will contain a string with the provider's name.

  - `:term` will be `:none` if no query parameters were given or the provider
    has no configured term parameters in the database (mostly relevant for
    social or email referers). If a configured term parameter was found it will
    be an unencoded string (possibly empty).
  """

  alias RefInspector.Database
  alias RefInspector.Parser
  alias RefInspector.Result

  @doc """
  Checks if RefInspector is ready to perform lookups.

  The `true == ready?` definition is made on the assumption that if there is
  at least one referer in the database the work intenden can be performed.

  Checking the state is done using the currently active database.
  Any potentially concurrent reload requests are not considered.
  """
  @spec ready?() :: boolean
  def ready?(), do: [] != Database.list()

  @doc """
  Parses a referer.
  """
  @spec parse(URI.t() | String.t() | nil) :: Result.t()
  def parse(nil), do: %Result{}
  def parse(""), do: %Result{}

  def parse(%URI{} = uri) do
    uri
    |> Parser.parse()
    |> Map.put(:referer, URI.to_string(uri))
  end

  def parse(ref) when is_binary(ref) do
    ref
    |> URI.parse()
    |> Parser.parse()
    |> Map.put(:referer, ref)
  end

  @doc """
  Reloads all databases.

  This process is done asynchronously in the background, so be aware that for
  some time the old data will be used for lookups.
  """
  @spec reload() :: :ok
  def reload(), do: GenServer.cast(Database, :reload)
end
