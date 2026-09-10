from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.models.user import User
from app.schemas.user import UserRead, UserUpdate, UserPreferences
from app.security.rbac import get_current_user

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserRead)
async def get_me(current_user: User = Depends(get_current_user)):
    roles = [ur.role.name for ur in current_user.roles if ur.role]
    return UserRead(
        id=str(current_user.id),
        email=current_user.email,
        full_name=current_user.full_name,
        phone_number=current_user.phone_number,
        district=current_user.district,
        state=current_user.state,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        roles=roles,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
    )


@router.put("/me", response_model=UserRead)
async def update_me(
    req: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    if req.full_name is not None:
        current_user.full_name = req.full_name
    if req.phone_number is not None:
        current_user.phone_number = req.phone_number
    if req.district is not None:
        current_user.district = req.district
    if req.state is not None:
        current_user.state = req.state

    await db.commit()
    await db.refresh(current_user)

    roles = [ur.role.name for ur in current_user.roles if ur.role]
    return UserRead(
        id=str(current_user.id),
        email=current_user.email,
        full_name=current_user.full_name,
        phone_number=current_user.phone_number,
        district=current_user.district,
        state=current_user.state,
        is_active=current_user.is_active,
        is_verified=current_user.is_verified,
        roles=roles,
        created_at=current_user.created_at,
        updated_at=current_user.updated_at,
    )


@router.get("/me/preferences", response_model=UserPreferences)
async def get_preferences(current_user: User = Depends(get_current_user)):
    # Default user preferences
    return UserPreferences(
        preferred_language="en",
        notifications_enabled=True,
        sms_alerts_enabled=False,
    )


@router.put("/me/preferences", response_model=UserPreferences)
async def update_preferences(
    prefs: UserPreferences,
    current_user: User = Depends(get_current_user),
):
    return prefs
