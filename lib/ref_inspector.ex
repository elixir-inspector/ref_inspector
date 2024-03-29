defmodule RefInspector do
  @moduledoc """
  Referer parser library.

  ## Preparation

  1. Verify your supervision setup according to `RefInspector.Supervisor`
  2. Revise the default configuration values of `RefInspector.Config` and
     adjust to your project/environment where necessary
  3. Download a copy of the parser database file(s) as outlined in
    `RefInspector.Downloader`

  ## Usage

      iex> RefInspector.parse("http://www.google.com/search?q=ref_inspector")
      %RefInspector.Result{
        medium: "search",
        referer: "http://www.google.com/search?q=ref_inspector",
        source: "Google",
        term: "ref_inspector"
      }

  Passing a referer string will result in a `%RefInspector.Result{}` returned
  with the following information (if available):

  - `:referer` will contain the unmodified referer passed to the parser.

  - `:medium` will be `:internal` (if configured), `:unknown` if no matching
    database entry could be found, or a string matching the entry in the
    database. Detecting a referer as `:internal` requires additional
    configuration (see `RefInspector.Config`).

  - `:source` will be `:unknown` if no known source could be detected.
    Otherwise it will contain a string with the provider's name.

  - `:term` will be `:none` if no query parameters were given or the provider
    has no configured term parameters in the database (mostly relevant for
    social or email referers). If a configured term parameter was found it will
    be an unencoded string (possibly empty).

  #### Note about Result Medium Atoms/Binaries

  The medium atoms `:unknown` and `:internal` are specially treated to reflect
  two special cases. One being reserved for completely unknown referers and
  one being for configured domains to not be parsed.

  Your database can still include `"unknown"` and `"internal"` sections. These
  will be parsed fully and returned using a binary as the medium instead of
  the aforementioned atoms.
  """

  alias RefInspector.Database
  alias RefInspector.Parser
  alias RefInspector.Result

  @doc """
  Checks if RefInspector is ready to perform lookups.

  The `true == ready?` definition is made on the assumption that if there is
  at least one referer in the database then lookups can be performed.

  Checking the state is done using the currently active database.
  Any potentially concurrent reload requests are not considered.
  """
  @spec ready?(atom) :: boolean
  def ready?(database \\ :default), do: [] != Database.list(database)

  @doc """
  Parses a referer.

  Passing an empty referer (`""` or `nil`) will directly return an empty result
  without accessing the database.
  """
  @spec parse(URI.t() | String.t() | nil, Keyword.t()) :: Result.t()
  def parse(ref, opts \\ [database: :default])

  def parse(nil, _), do: %Result{referer: nil}
  def parse("", _), do: %Result{referer: ""}

  def parse(ref, opts) when is_binary(ref), do: ref |> URI.parse() |> parse(opts)

  def parse(%URI{} = uri, opts) do
    uri
    |> Parser.parse(opts)
    |> Map.put(:referer, URI.to_string(uri))
  end

  @doc """
  Reloads all databases.

  You can pass `[async: true|false]` to define if the reload should happen
  in the background or block your calling process until completed.
  """
  @spec reload(Keyword.t()) :: :ok
  def reload(opts \\ []) do
    [async: true, database: :default]
    |> Keyword.merge(opts)
    |> Database.reload()
  end
end
