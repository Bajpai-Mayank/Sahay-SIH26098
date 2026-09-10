import os
from pathlib import Path
from typing import Optional
import aiofiles

from app.storage.base import StorageProvider
from app.config import get_settings

settings = get_settings()


class LocalStorageProvider(StorageProvider):
    def __init__(self, base_path: Optional[str] = None):
        self.base_path = Path(base_path or settings.STORAGE_PATH)
        self.base_path.mkdir(parents=True, exist_ok=True)

    async def save_file(self, path: str, content: bytes, content_type: str = "audio/wav") -> str:
        target_path = self.base_path / path
        target_path.parent.mkdir(parents=True, exist_ok=True)
        async with aiofiles.open(target_path, "wb") as f:
            await f.write(content)
        return str(target_path)

    async def get_file(self, path: str) -> Optional[bytes]:
        target_path = self.base_path / path
        if not target_path.exists():
            return None
        async with aiofiles.open(target_path, "rb") as f:
            return await f.read()

    async def delete_file(self, path: str) -> bool:
        target_path = self.base_path / path
        if target_path.exists():
            target_path.unlink()
            return True
        return False
