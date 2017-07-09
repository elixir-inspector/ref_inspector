# Changelog

## v0.15.0-dev

- Enhancements
    - The database downloader has been promoted to a directly usable module

## v0.14.0 (2017-05-31)

- Enhancements
    - Empty referers (`""` or `nil`) now return a result without performing
      an actual lookup
    - System environment configuration can set an optional default value
      to be used if the environment variable is unset

- Bug fixes
    - Properly handles `nil` values passed to the lookup

- Backwards incompatible changes
    - Support for single `:remote_url` download configuration has been removed

## v0.13.0 (2016-11-19)

- Enhancements
    - Downloaded files can be automatically stored under a custom filename
      differing from the url basename
    - Multiple files can be configured for download

- Deprecations
    - Configuring a single `:remote_url` for download has been deprecated

## v0.12.0 (2016-09-22)

- Enhancements
    - Multiple databases can be configured to load during startup.
      Lookups are done in order until a match is found

- Backwards incompatible changes
    - Downloaded databases are stored under the basename of the remote file
      instead of the filename of the "first configured database"
    - Support for `:yaml` as database configuration has been removed

## v0.11.0 (2016-09-07)

- Enhancements
    - Remote url of database file is now configurable

- Deprecations
    - Configuring a single `:yaml` as the database has been deprecated

- Backwards incompatible changes
    - Support for loading a database file at runtime
      using `RefInspector.load/1` has been removed

## v0.10.0 (2016-08-19)

- Enhancements
    - Database download is done using hackney in order to prepare an
      upcoming auto-update feature
    - If the initial load of the database (during process initialisation)
      fails a message will be sent through `Logger.info/1`

- Backwards incompatible changes
    - Downloads are now done using `:hackney` instead of `mix`. This may force
      you to manually reconfigure the client
    - Minimum required elixir version is now "~> 1.2"
    - Minimum required erlang version is now "~> 18.0"

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
