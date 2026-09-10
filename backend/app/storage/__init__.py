from app.storage.base import StorageProvider
from app.storage.local import LocalStorageProvider
from app.storage.supabase import SupabaseStorageProvider
from app.config import get_settings

settings = get_settings()


def get_storage() -> StorageProvider:
    if settings.STORAGE_BACKEND == "supabase":
        return SupabaseStorageProvider()
    return LocalStorageProvider()


__all__ = ["StorageProvider", "LocalStorageProvider", "SupabaseStorageProvider", "get_storage"]
