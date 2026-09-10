from typing import Optional
import httpx

from app.storage.base import StorageProvider
from app.storage.local import LocalStorageProvider
from app.config import get_settings

settings = get_settings()


class SupabaseStorageProvider(StorageProvider):
    """
    Supabase Storage bucket integration.
    Falls back to LocalStorageProvider if Supabase credentials are not configured.
    """

    def __init__(self):
        self.url = settings.SUPABASE_URL
        self.key = settings.effective_supabase_secret_key or settings.effective_supabase_publishable_key
        self.bucket = settings.STORAGE_BUCKET
        self._local_fallback = LocalStorageProvider()

    def is_configured(self) -> bool:
        return bool(self.url and self.key and not self.url.startswith("https://your-project"))

    async def save_file(self, path: str, content: bytes, content_type: str = "audio/wav") -> str:
        if not self.is_configured():
            return await self._local_fallback.save_file(path, content, content_type)

        headers = {
            "Authorization": f"Bearer {self.key}",
            "Content-Type": content_type,
            "x-upsert": "true",
        }
        endpoint = f"{self.url.rstrip('/')}/storage/v1/object/{self.bucket}/{path}"
        async with httpx.AsyncClient() as client:
            resp = await client.post(endpoint, headers=headers, content=content)
            resp.raise_for_status()
            return f"{self.bucket}/{path}"

    async def get_file(self, path: str) -> Optional[bytes]:
        if not self.is_configured():
            return await self._local_fallback.get_file(path)

        headers = {"Authorization": f"Bearer {self.key}"}
        endpoint = f"{self.url.rstrip('/')}/storage/v1/object/authenticated/{self.bucket}/{path}"
        async with httpx.AsyncClient() as client:
            resp = await client.get(endpoint, headers=headers)
            if resp.status_code == 200:
                return resp.content
            return None

    async def delete_file(self, path: str) -> bool:
        if not self.is_configured():
            return await self._local_fallback.delete_file(path)

        headers = {"Authorization": f"Bearer {self.key}"}
        endpoint = f"{self.url.rstrip('/')}/storage/v1/object/{self.bucket}"
        async with httpx.AsyncClient() as client:
            resp = await client.delete(endpoint, headers=headers, json={"prefixes": [path]})
            return resp.status_code == 200
