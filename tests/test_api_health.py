import pytest
import requests

TIMEOUT = 15


@pytest.mark.external
def test_smhi_air_quality_api():
    """SMHI Datavårdluft API returns service metadata."""
    url = "https://datavardluft.smhi.se/52North/api/"
    resp = requests.get(url, timeout=TIMEOUT)
    assert resp.status_code == 200
    data = resp.json()
    assert isinstance(data, list)
    assert len(data) > 0


@pytest.mark.external
def test_smhi_weather_api():
    """SMHI MetObs API returns version metadata with resource list."""
    url = "https://opendata-download-metobs.smhi.se/api/version/latest.json"
    resp = requests.get(url, timeout=TIMEOUT)
    assert resp.status_code == 200
    data = resp.json()
    assert "resource" in data or "link" in data


@pytest.mark.external
def test_smhi_hydrology_api():
    """SMHI HydroObs API returns version metadata with resource list."""
    url = "https://opendata-download-hydroobs.smhi.se/api/version/latest.json"
    resp = requests.get(url, timeout=TIMEOUT)
    assert resp.status_code == 200
    data = resp.json()
    assert "resource" in data or "link" in data


@pytest.mark.external
def test_overpass_primary_api():
    """Overpass primary API returns non-empty status."""
    url = "https://overpass-api.de/api/status"
    resp = requests.get(url, timeout=TIMEOUT)
    assert resp.status_code == 200
    assert len(resp.text.strip()) > 0


@pytest.mark.external
@pytest.mark.xfail(reason="Fallback server may be less reliable")
def test_overpass_fallback_api():
    """Overpass fallback API returns status."""
    url = "https://overpass.private.coffee/api/status"
    resp = requests.get(url, timeout=TIMEOUT)
    assert resp.status_code == 200
