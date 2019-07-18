# Changelog

## v1.2.0-dev

- Enhancements
    - Warnings when starting without a database available can be silenced

- Bug fixes
    - The mix download task now works properly with initializer modules

## v1.1.0 (2019-07-03)

- Enhancements
    - Configuring `startup_sync: true` allows you to ensure a synchronous database load is attempted before allowing to parse referers
    - Database entries are now stored in a single named table instead of using an intermediate reference table
    - Default configuration entries for files and urls are available through `RefInspector.Config.default_files/0` and `RefInspector.Config.default_urls/0`
    - Output of mix task `ref_inspector.download` can be prevented by passing `--quiet` upon invocation. This does NOT imply `--force` and will still ask for confirmation
    - Passing `async: false` to `RefInspector.reload/1` allows you to block your calling process until the reload has finished
    - The library used to download the database files can be changed by configuring a module implementing the `RefInspector.Downloader.Adapter` behaviour
    - The library used to read YAML files can be changed by using the `:yaml_file_reader` configuration

- Deprecations
    - Several functions are now declared internal and will result in a `Logger.info/1` message when called until they will be eventually removed:
        - `RefInspector.Downloader.path_local/1`
        - `RefInspector.Downloader.path_remote/1`
        - `RefInspector.Downloader.read_remote/1`
        - `RefInspector.Downloader.README.path_local/0`
        - `RefInspector.Downloader.README.path_priv/0`

## v1.0.0 (2018-11-24)

- Ownership has been transferred to the [`elixir-inspector`](https://github.com/elixir-inspector) organisation

- Enhancements
    - Documentation is now available inline (`@moduledoc`, ...) with the `README.md` file targeting the repository (development) instead of releases
    - Downloading the databases ensures hackney is started to allow calling `mix run --no-start -e "RefInspector.Downloader.download()"`
    - Initializer modules can be defined with additional arguments by using `{mod, fun, args}`
    - Parsing can now be performed on `URI.t()` referers
    - The default database path has been set to `Application.app_dir(:ref_inspector, "priv")`
    - The download mix task will now exit with code `1` if it aborts due to missing configuration

- Backwards incompatible changes
    - Internal parser process pooling has been removed. If you require pooling you need to manually wrap `RefInspector.parse/1`
    - Medium information in the result struct is now returned as a `String.t()` instead of an `atom`. The only exceptions are `:unknown` and `:internal` referers
    - Minimum required elixir version is now `~> 1.5`
    - Support for `{:system, var}` configuration has been removed

## v0.20.0 (2018-07-22)

- Enhancements
    - Parsing speed has been improved and made more independent of database size
    - The configurable `:init` method will now be automatically executed when running the mix download task without manually ensuring the application is started

- Deprecations
    - Accessing the system environment by configuring `{:system, var}` or `{:system, var, default}` will now result in a `Logger.info/1` message and will stop working in a future release

- Backwards incompatible changes
    - The mix task alias `ref_inspector.yaml.download` has been removed
    - The reload alias `RefInspector.reload_databases/0` has been removed

## v0.19.0 (2018-02-13)

- Enhancements
    - Finding the data table is now done via a named lookup table instead of calling the database state server
    - Old data tables are deleted with a configurable delay after reloading to avoid race conditions (and the resulting empty lookup responses)
    - If you need to check if the database is loaded (i.e. "no longer empty") you can use `RefInspector.ready?/0`

## v0.18.0 (2017-12-31)

- Enhancements
    - Download task name has been shortened to `ref_inspector.download`
    - Reloading the database if part of the configuration is missing or broken (database path / database files) will issue a warning while resuming operation with an empty database

- Deprecations
    - The reload method `RefInspector.reload_databases/0` has been renamed to `RefInspector.reload/0`
    - The mix task `ref_inspector.yaml.download` has been renamed. The alias in place will be removed in a future version

- Bug fixes
    - ETS tables are now properly cleaned after reload

## v0.17.0 (2017-11-15)

- Enhancements
    - All databases can be reloaded (asynchronously) using `RefInspector.reload_databases/0`
    - Configuration can be done on supervisor (re-) start by setting a `{mod, fun}` tuple for the config key `:init`. This method will be called without arguments
    - When using the mix download task with a default remote configuration an information README file is placed next to the downloaded file(s)

- Soft deprecations (no warnings)
    - Support for `{:system, "ENV_VARIABLE"}` configuration has been removed from the documentation. It will eventually be removed completely after a proper deprecation phase

## v0.16.0 (2017-09-24)

- Backwards incompatible changes
    - Minimum required elixir version is now `~> 1.3`

## v0.15.0 (2017-09-12)

- Enhancements
    - Supervision can now be done without starting the application
    - The database downloader has been promoted to a directly usable module

## v0.14.0 (2017-05-31)

- Enhancements
    - Empty referers (`""` or `nil`) now return a result without performing an actual lookup
    - System environment configuration can set an optional default value to be used if the environment variable is unset

- Bug fixes
    - Properly handles `nil` values passed to the lookup

- Backwards incompatible changes
    - Support for single `:remote_url` download configuration has been removed

## v0.13.0 (2016-11-19)

- Enhancements
    - Downloaded files can be automatically stored under a custom filename differing from the url basename
    - Multiple files can be configured for download

- Deprecations
    - Configuring a single `:remote_url` for download has been deprecated

## v0.12.0 (2016-09-22)

- Enhancements
    - Multiple databases can be configured to load during startup. Lookups are done in order until a match is found

- Backwards incompatible changes
    - Downloaded databases are stored under the basename of the remote file instead of the filename of the "first configured database"
    - Support for `:yaml` as database configuration has been removed

## v0.11.0 (2016-09-07)

- Enhancements
    - Remote url of database file is now configurable

- Deprecations
    - Configuring a single `:yaml` as the database has been deprecated

- Backwards incompatible changes
    - Support for loading a database file at runtime using `RefInspector.load/1` has been removed

## v0.10.0 (2016-08-19)

- Enhancements
    - Database download is done using hackney in order to prepare an upcoming auto-update feature
    - If the initial load of the database (during process initialisation) fails a message will be sent through `Logger.info/1`

- Backwards incompatible changes
    - Downloads are now done using `:hackney` instead of `mix`. This may force you to manually reconfigure the client
    - Minimum required elixir version is now `~> 1.2`
    - Minimum required erlang version is now `~> 18.0`

## v0.9.0 (2016-03-30)

- Enhancements
    - Database is reloaded if the storage process gets restarted
    - Path can be configured by accessing the system environment
    - Referer database can be reloaded usind `RefInspector.load/1`

- Backwards incompatible changes
    - Reloading the database drops previously loaded (unconfigured) entries

## v0.8.0 (2015-07-18)

- Enhancements
    - Domains to be detected as `:internal` can be configured

## v0.7.0 (2015-06-01)

- Enhancements
    - Dependencies not used in production builds are marked as optional
    - Displays expanded download path for `mix ref_inspector.yaml.download`
    - Verification script now automatically downloads database file
    - Worker pool options are no longer defined at compile time

- Backwards incompatible changes
    - Pool configuration is now expected to be a `Keyword.t`

## v0.6.0 (2015-04-03)

- Initial Release
