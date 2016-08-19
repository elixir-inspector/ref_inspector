# Changelog

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
