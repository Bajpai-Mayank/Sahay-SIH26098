from abc import ABC, abstractmethod
from typing import Optional, Tuple


class StorageProvider(ABC):
    @abstractmethod
    async def save_file(self, path: str, content: bytes, content_type: str = "audio/wav") -> str:
        """Save file bytes and return access URI or file identifier."""
        pass

    @abstractmethod
    async def get_file(self, path: str) -> Optional[bytes]:
        """Retrieve file bytes."""
        pass

    @abstractmethod
    async def delete_file(self, path: str) -> bool:
        """Delete file at path."""
        pass
