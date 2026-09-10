from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import get_db
from app.services.auth_service import AuthService
from app.schemas.auth import LoginRequest, RegisterRequest, TokenResponse, RefreshTokenRequest, UserSummary
from app.schemas.common import APIResponse

router = APIRouter(prefix="/auth", tags=["Authentication"])


@router.post("/register", response_model=TokenResponse)
async def register(req: RegisterRequest, db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    try:
        user = await auth_service.register_user(
            email=req.email,
            password=req.password,
            full_name=req.full_name,
            phone_number=req.phone_number,
            role_name=req.role or "VICTIM",
        )
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_400_BAD_REQUEST, detail=str(e))

    access_token, refresh_token, expires_in = auth_service.generate_tokens(user)
    roles = [ur.role.name for ur in user.roles if ur.role]

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=UserSummary(
            id=str(user.id),
            email=user.email,
            full_name=user.full_name,
            roles=roles,
            is_active=user.is_active,
        ),
    )


@router.post("/login", response_model=TokenResponse)
async def login(req: LoginRequest, db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    user = await auth_service.authenticate_user(req.email, req.password)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    access_token, refresh_token, expires_in = auth_service.generate_tokens(user)
    roles = [ur.role.name for ur in user.roles if ur.role]

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=UserSummary(
            id=str(user.id),
            email=user.email,
            full_name=user.full_name,
            roles=roles,
            is_active=user.is_active,
        ),
    )


@router.post("/refresh", response_model=TokenResponse)
async def refresh(req: RefreshTokenRequest, db: AsyncSession = Depends(get_db)):
    auth_service = AuthService(db)
    try:
        access_token, refresh_token, expires_in = await auth_service.refresh_tokens(req.refresh_token)
    except ValueError as e:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail=str(e))

    # Get user to return summary
    from app.security.jwt import decode_token
    payload = decode_token(access_token)
    user = await auth_service.get_user_by_id(payload["sub"])
    roles = [ur.role.name for ur in user.roles if ur.role]  # type: ignore

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        token_type="bearer",
        expires_in=expires_in,
        user=UserSummary(
            id=str(user.id),  # type: ignore
            email=user.email,  # type: ignore
            full_name=user.full_name,  # type: ignore
            roles=roles,
            is_active=user.is_active,  # type: ignore
        ),
    )


@router.post("/logout")
async def logout():
    return {"success": True, "message": "Logged out successfully"}
