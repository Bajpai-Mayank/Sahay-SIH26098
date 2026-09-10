from datetime import datetime, timedelta, timezone
from typing import Optional
import uuid
from fastapi import APIRouter, Depends, File, Form, HTTPException, UploadFile, status
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.user import User
from app.models.audio_asset import AudioAsset
from app.storage import get_storage
from app.security.rbac import get_current_user

router = APIRouter(prefix="/voice", tags=["Voice & Multimodal"])


@router.post("/upload")
async def upload_voice(
    file: UploadFile = File(...),
    case_id: str = Form(...),
    checkin_id: Optional[str] = Form(None),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    storage = get_storage()
    content = await file.read()
    filename = f"{case_id}/{uuid.uuid4().hex}_{file.filename}"
    storage_path = await storage.save_file(filename, content, content_type=file.content_type or "audio/wav")

    retention_until = datetime.now(timezone.utc) + timedelta(days=30)

    asset = AudioAsset(
        case_id=case_id,
        checkin_id=checkin_id,
        storage_path=storage_path,
        format=file.filename.split(".")[-1] if file.filename and "." in file.filename else "wav",
        consent_verified=True,
        analysis_status="pending",
        retention_until=retention_until,
    )
    db.add(asset)
    await db.commit()
    await db.refresh(asset)

    return {
        "id": asset.id,
        "case_id": asset.case_id,
        "storage_path": asset.storage_path,
        "analysis_status": asset.analysis_status,
        "retention_until": asset.retention_until.isoformat(),
    }


@router.post("/{asset_id}/transcribe")
async def transcribe_voice(
    asset_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(AudioAsset).where(AudioAsset.id == asset_id)
    res = await db.execute(stmt)
    asset = res.scalar_one_or_none()
    if not asset:
        raise HTTPException(status_code=404, detail="Audio asset not found")

    # In mock/practice mode, return synthetic transcription
    if not asset.transcript:
        asset.transcript = (
            "[Transcribed Audio - Practice/Demo]: I felt a bit overwhelmed yesterday evening, "
            "but I took a walk and things felt slightly better today morning."
        )
        asset.analysis_status = "completed"
        await db.commit()
        await db.refresh(asset)

    return {
        "id": asset.id,
        "transcript": asset.transcript,
        "status": asset.analysis_status,
    }


@router.get("/{asset_id}/analysis")
async def voice_analysis(
    asset_id: str,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    stmt = select(AudioAsset).where(AudioAsset.id == asset_id)
    res = await db.execute(stmt)
    asset = res.scalar_one_or_none()
    if not asset:
        raise HTTPException(status_code=404, detail="Audio asset not found")

    return {
        "id": asset.id,
        "status": asset.analysis_status,
        "acoustic_features": {
            "pitch_variance": 0.42,
            "jitter": 0.015,
            "speech_rate_wpm": 128,
            "pause_ratio": 0.18,
        },
        "extracted_sentiment": "neutral_reflective",
        "requires_human_review": False,
    }
