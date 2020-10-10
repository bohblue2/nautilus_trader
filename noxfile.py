import nox
from nox.sessions import Session
import nox_poetry


@nox.session(python=["3.8"])
def test(session: Session) -> None:
    """Run the test suite."""
    nox_poetry.install(session, nox_poetry.WHEEL)
    nox_poetry.install(session, "pytest", "pytest-cov", "pytest-xdist")
    session.run("pytest", *session.posargs)


@nox.session(python=["3.8"], reuse_venv=True)
def coverage(session: Session) -> None:
    """Run the test suite."""
    nox_poetry.install(session, nox_poetry.SDIST)
    nox_poetry.install(session, "pytest", "pytest-cov", "pytest-xdist")
    session.run("pytest", "--cov=nautilus_trader", *session.posargs)
    # session.run("codecov")


@nox.session(python=["3.8"], reuse_venv=True)
def profile(session: Session) -> None:
    """Run the test suite."""
    # session.virtualenv.env.update({"PROFILING_MODE": "true"})
    # session.run("python", "scripts/cleanup.py")
    session.run("pip", "list")
    nox_poetry.install(session, nox_poetry.SDIST)
    nox_poetry.install(session, "pytest", "pytest-cov", "pytest-xdist")
    session.run("pytest", "--cov=nautilus_trader", "--cov-report=xml", *session.posargs)
    # session.run("codecov")
