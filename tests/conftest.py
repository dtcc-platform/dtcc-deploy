import pytest


def pytest_configure(config):
    config.addinivalue_line(
        "markers", "external: tests that require network access to external APIs"
    )
