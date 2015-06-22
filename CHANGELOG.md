# Changelog

## v0.8.0-dev

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
