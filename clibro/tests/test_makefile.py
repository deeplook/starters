"""Tests for the Makefile."""

import shutil
import subprocess
import tempfile
from collections.abc import Generator
from pathlib import Path

import pytest


def make_dirty_workspace(path: Path) -> None:
    """
    Helper function to create dummy files in a given path.
    """
    (path / "build").mkdir(exist_ok=True)
    (path / "dist").mkdir(exist_ok=True)
    (path / "__pycache__").mkdir(exist_ok=True)
    (path / "test.pyc").touch()
    (path / "test.pyo").touch()
    (path / "test.egg-info").mkdir(exist_ok=True)


@pytest.fixture
def linting_error_file() -> Generator[Path, None, None]:
    """
    Creates a temporary Python file with a linting error and ensures its cleanup.
    """
    temp_file_path = Path("tests/temp_lint_test.py")
    temp_file_path.write_text("import os\n")
    yield temp_file_path
    if temp_file_path.exists():
        temp_file_path.unlink()


def run_make_target(target: str, cwd: Path | str = ".") -> subprocess.CompletedProcess:
    """
    A helper function to run a Makefile target and capture its output.
    """
    return subprocess.run(
        ["make", target],
        capture_output=True,
        text=True,
        check=False,
        cwd=str(cwd),
    )


def _test_makefile_help_target() -> None:
    """
    Tests the 'make help' command.
    """
    result = run_make_target("help")

    assert result.returncode == 0, f"Makefile target 'help' failed with stderr: {result.stderr}"
    assert "Available commands:" in result.stdout
    assert "install" in result.stdout
    assert "test" in result.stdout
    assert "lint" in result.stdout


def test_makefile_clean_target() -> None:
    """
    Tests the 'make clean' command in an isolated directory.
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        shutil.copy("Makefile", tmp_path)
        make_dirty_workspace(tmp_path)

        result = run_make_target("clean", cwd=tmp_path)

        assert result.returncode == 0, f"Makefile target 'clean' failed with stderr: {result.stderr}"
        assert not (tmp_path / "build").exists()
        assert not (tmp_path / "dist").exists()
        assert not (tmp_path / "__pycache__").exists()
        assert not (tmp_path / "test.pyc").exists()
        assert not (tmp_path / "test.pyo").exists()
        assert not (tmp_path / "test.egg-info").exists()


def test_makefile_lint_target_success() -> None:
    """
    Tests the 'make lint' command on a clean codebase.
    """
    result = run_make_target("lint")
    assert result.returncode == 0, f"Makefile target 'lint' failed with stderr: {result.stderr}"


def test_makefile_lint_target_failure(linting_error_file: Path) -> None:
    """
    Tests that the 'make lint' command fails on a dirty codebase.
    """
    result = run_make_target("lint")

    assert result.returncode != 0, "Makefile target 'lint' should have failed but it passed."
    assert "F401" in result.stdout, f"Expected linting error F401 not found in stdout: {result.stdout}"
    assert "imported but unused" in result.stdout, (
        f"Expected 'imported but unused' not found in stdout: {result.stdout}"
    )


def test_makefile_dist_target() -> None:
    """
    Tests the 'make dist' command in an isolated directory.
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        shutil.copy("Makefile", tmp_path)
        shutil.copy("pyproject.toml", tmp_path)
        shutil.copy("README.md", tmp_path)
        shutil.copytree("src", tmp_path / "src")

        result = run_make_target("dist", cwd=tmp_path)

        assert result.returncode == 0, f"Makefile target 'dist' failed with stderr: {result.stderr}"
        assert (tmp_path / "dist").exists()
        assert any((tmp_path / "dist").glob("*.whl"))
        assert any((tmp_path / "dist").glob("*.tar.gz"))


def test_makefile_distclean_target() -> None:
    """
    Tests the 'make distclean' command in an isolated directory.
    """
    with tempfile.TemporaryDirectory() as tmpdir:
        tmp_path = Path(tmpdir)
        shutil.copy("Makefile", tmp_path)
        make_dirty_workspace(tmp_path)
        (tmp_path / ".venv").mkdir(exist_ok=True)

        result = run_make_target("distclean", cwd=tmp_path)

        assert result.returncode == 0, f"Makefile target 'distclean' failed with stderr: {result.stderr}"
        assert not (tmp_path / ".venv").exists()
        assert not (tmp_path / "build").exists()
        assert not (tmp_path / "dist").exists()
