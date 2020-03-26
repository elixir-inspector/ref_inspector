defmodule RefInspector.Config do
  @moduledoc """
  Module to simplify access to configuration values with default values.

  There should be no configuration required to start using `:ref_inspector` if
  you rely on the default values:

      config :ref_inspector,
        database_files: ["referers.yml"],
        database_path: Application.app_dir(:ref_inspector, "priv"),
        http_opts: [],
        remote_urls: [{"referers.yml", "https://s3-eu-west-1.amazonaws.com/snowplow-hosted-assets/third-party/referer-parser/referers-latest.yml"}],
        startup_silent: false,
        startup_sync: true,
        yaml_file_reader: {:yamerl_constr, :file, [[:str_node_as_binary]]}

  The default `:database_path` is evaluated at runtime and not compiled into
  a release!

  ## How to Configure

  There are two ways to change the configuration values with the preferred way
  depending on your environment and personal taste.

  ### Static Configuration

  If you can ensure the configuration are static and not dependent on i.e. the
  server your application is running on, you can use a static approach by
  modifying your `config.exs` file:

      config :ref_inspector,
        database_files: ["referers_search.yml", "referers_social.yml"],
        database_path: "/path/to/ref_inspector/database_files"

  ### Dynamic Configuration

  If a compile time configuration is not possible or does not match the usual
  approach taken in your application you can use a runtime approach.

  This is done by defining an initializer module that will automatically be
  called by `RefInspector.Supervisor` upon startup/restart. The configuration
  is expected to consist of a `{mod, fun}` or `{mod, fun, args}` tuple:

      # {mod, fun}
      config :ref_inspector,
        init: {MyInitModule, :my_init_mf}

      # {mod, fun, args}
      config :ref_inspector,
        init: {MyInitModule, :my_init_mfa, [:foo, :bar]}

      defmodule MyInitModule do
        @spec my_init_mf() :: :ok
        def my_init_mf(), do: my_init_mfa(:foo, :bar)

        @spec my_init_mfa(atom, atom) :: :ok
        def my_init_mfa(:foo, :bar) do
          priv_dir = Application.app_dir(:my_app, "priv")

          Application.put_env(:ref_inspector, :database_path, priv_dir)
        end
      end

  The function is required to always return `:ok`.

  ## Startup Behaviour

  Databases are loaded synchronously when starting the application.

  You can change this behaviour to have the application force an asynchronous
  database loading during the initial startup:

      config :ref_inspector,
        startup_sync: false

  This can lead to the first parsing calls to work with an empty database
  and therefore not return the results you expect.

  ### Starting Silently

  When starting the application you will receive warnings if the database is
  not available. If you want to hide these messages you can configure the
  startup the be completely silent:

      config :ref_inspector,
        startup_silent: true

  This will automatically be set when calling the mix download task.

  ## Database Configuration

  Configuring the database to use can be done using three related values:

  - `:database_files`
  - `:database_path`
  - `:remote_urls`

  The `:database_path` is the directory to look for when loading the databases.
  It is also the place where `RefInspector.Downloader` stores a copy of the
  configured files.

  For the actual files loaded there is `:database_files`, a list of filenames
  to load in the order specified. All files are expected to be inside the
  configured database path.

  When downloading the databases through `RefInspector.Downloader` the value
  `:remote_urls` is of utmost importance. It defines where each file is located.

      config :ref_inspector,
        remote_urls: [
          "http://example.com/database.yml",
          {"database_local.yml", "http://example.com/database_remote.yml"}
        ]

  To configure a remote database name you can either define a plain URL. It will
  be stored locally under the filename that is extracted from the url. In above
  example that would be `"database.yml"`.

  If the remote and local names match you can configure a `{local, remote}`
  tuple to deactivate the automatic name extraction.

  ### Internal Domains

  To exclude some domains from parsing you can mark
  them as `:internal` using your configuration:

      config :ref_inspector,
        internal: ["www.example.com", "www.example.org"]

  If a referer matches one of the configured
  domains (== ends with, paths ignored!), it will return a result with
  the medium `:internal`. Both `:source` and `:term` will be left at the
  initial/unknown state not intended for further processing.

  ## Download Configuration

  Using the default configuration all download requests for your database files
  are done using [`:hackney`](https://hex.pm/packages/hackney). To pass custom
  configuration values to hackney you can use the key `:http_opts`:

      config :ref_inspector,
        http_opts: [proxy: "http://mycompanyproxy.com"]

  Please see
  [`:hackney.request/5`](https://hexdocs.pm/hackney/hackney.html#request-5)
  for a complete list of available options.

  If you want to change the library used to download the databases you can
  configure a module implementing the `RefInspector.Downloader.Adapter`
  behaviour:

      config :ref_inspector,
        downloader_adapter: MyDownloaderAdapter

  ## YAML File Reader Configuration

  By default the library [`:yamerl`](https://hex.pm/packages/yamerl) will
  be used to read and decode the yaml database files. You can configure this
  reader to be a custom module:

      config :ref_inspector,
        yaml_file_reader: {module, function}

      config :ref_inspector,
        yaml_file_reader: {module, function, extra_args}

  The configured module will receive the file to read as the first argument with
  any optionally configured extra arguments after that.
  """

  @upstream_remote "https://s3-eu-west-1.amazonaws.com/snowplow-hosted-assets/third-party/referer-parser/referers-latest.yml"

  @default_files ["referers.yml"]
  @default_urls [{"referers.yml", @upstream_remote}]

  @default_downloader_adapter RefInspector.Downloader.Adapter.Hackney
  @default_yaml_reader {:yamerl_constr, :file, [[:str_node_as_binary]]}

  @doc """
  Provides access to configuration values with optional environment lookup.
  """
  @spec get(atom, term) :: term
  def get(key, default \\ nil) do
    Application.get_env(:ref_inspector, key, default)
  end

  @doc """
  Returns the list of configured database files.
  """
  @spec database_files() :: [binary]
  def database_files do
    case get(:database_files) do
      nil -> default_files()
      files when is_list(files) -> files
    end
  end

  @doc """
  Returns the configured database path.

  If the path is not defined the `priv` dir of `:ref_inspector`
  as returned by `Application.app_dir(:ref_inspector, "priv")` will be used.
  """
  @spec database_path() :: String.t()
  def database_path do
    case get(:database_path) do
      nil -> Application.app_dir(:ref_inspector, "priv")
      path -> path
    end
  end

  @doc """
  Returns the default list of database files.
  """
  @spec default_files() :: [binary]
  def default_files, do: @default_files

  @doc """
  Returns the default list of database urls.
  """
  @spec default_urls() :: [{binary, binary}]
  def default_urls, do: @default_urls

  @doc """
  Returns whether the remote database matches the default.
  """
  @spec default_remote_database?() :: boolean
  def default_remote_database?, do: yaml_urls() == default_urls()

  @doc """
  Returns the configured downloader adapter module.

  The modules is expected to adhere to the behaviour defined in
  `RefInspector.Downloader.Adapter`.
  """
  @spec downloader_adapter() :: module
  def downloader_adapter, do: get(:downloader_adapter, @default_downloader_adapter)

  @doc """
  Calls the optionally configured init method.
  """
  @spec init_env() :: :ok
  def init_env do
    case get(:init) do
      nil -> :ok
      {mod, fun} -> apply(mod, fun, [])
      {mod, fun, args} -> apply(mod, fun, args)
    end
  end

  @doc """
  Returns the `{mod, fun, extra_args}` to be used when reading a yaml file.
  """
  @spec yaml_file_reader() :: {module, atom, [term]}
  def yaml_file_reader do
    case get(:yaml_file_reader) do
      {_, _, _} = mfa -> mfa
      {mod, fun} -> {mod, fun, []}
      _ -> @default_yaml_reader
    end
  end

  @doc """
  Returns the remote urls of the database file.
  """
  @spec yaml_urls() :: [String.t() | {String.t(), String.t()}]
  def yaml_urls do
    case get(:remote_urls) do
      files when is_list(files) and 0 < length(files) -> files
      _ -> default_urls()
    end
  end
end
