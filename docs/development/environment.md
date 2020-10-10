# Environment, Setup & Packaging

`nautilus_trader` uses [Poetry](https://python-poetry.org) to manage packaging, dependencies, metadata, and some tooling config. It uses [nox](https://nox.thea.codes/en/stable/) to manage testing and tooling integration. [pipx](https://pipxproject.github.io/pipx/) can be used to install and manage `poetry` and `nox` in a global context.

## Initial setup
### System prerequisites
1. Install [pipx](https://pipxproject.github.io/pipx/) -> [installation](https://pipxproject.github.io/pipx/installation/)
2. Use `pipx` to install [poetry]((https://python-poetry.org)), [nox]((https://nox.thea.codes/en/stable/)), and [nox-poetry](https://nox-poetry.readthedocs.io/en/latest/):
  - `pipx install poetry`
  - `pipx install nox`
  - `pipx inject nox nox-poetry`

### `nautilus_trader` repo setup
1. `git clone git@github.com:nautechsystems/nautilus_trader.git nautilus_trader`
2. `git checkout develop`
3. `poetry install`


### Run backtest demo
`poetry run python examples/backtest/backtest_console.py`

## Testing
### All tests
`nox -s test`

### Specific tests
`nox -s test -- tests/unit_tests/execution`

### Tests with coverage
`nox -s coverage`

### Tests with profiling
`nox -s profile`
