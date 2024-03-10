from typing import Optional

from nautilus_trader.config import InstrumentProviderConfig
from nautilus_trader.config.common import NautilusConfig


class EbestInstrumentProviderConfig(InstrumentProviderConfig, frozen=True):
    cache_expired_cron: Optional[str] = "20 7 * * *"
    time_zone: Optional[str] = "Asia/Seoul"


class EbestClientConfig(NautilusConfig, frozen=True):
    rest_base_url: str = "https://openapi.ebestsec.co.kr:8080"
    websocket_base_url: str = "wss://openapi.ebestsec.co.kr:9443"
    app_key: Optional[str] = None
    app_secret: Optional[str] = None
