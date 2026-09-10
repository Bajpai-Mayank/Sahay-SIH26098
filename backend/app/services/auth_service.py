import uuid
from typing import Optional, Tuple
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.models.user import User
from app.models.role import Role, UserRole, RoleName
from app.security.password import verify_password, get_password_hash
from app.security.jwt import create_access_token, create_refresh_token, decode_token
from app.config import get_settings

settings = get_settings()


class AuthService:
    def __init__(self, db: AsyncSession):
        self.db = db

    async def authenticate_user(self, email: str, password: str) -> Optional[User]:
        stmt = (
            select(User)
            .options(selectinload(User.roles).selectinload(UserRole.role))
            .where(User.email == email.lower().strip())
        )
        res = await self.db.execute(stmt)
        user = res.scalar_one_or_none()
        if not user:
            return None
        if not verify_password(password, user.password_hash):
            return None
        if not user.is_active:
            return None
        return user

    async def register_user(
        self,
        email: str,
        password: str,
        full_name: str,
        phone_number: Optional[str] = None,
        role_name: str = "VICTIM",
    ) -> User:
        # Check if already exists
        check_stmt = select(User).where(User.email == email.lower().strip())
        check_res = await self.db.execute(check_stmt)
        if check_res.scalar_one_or_none():
            raise ValueError("Email is already registered")

        user = User(
            email=email.lower().strip(),
            password_hash=get_password_hash(password),
            full_name=full_name.strip(),
            phone_number=phone_number.strip() if phone_number else None,
            is_active=True,
            is_verified=True,
        )
        self.db.add(user)
        await self.db.flush()

        # Find or create role
        role_stmt = select(Role).where(Role.name == role_name.upper())
        role_res = await self.db.execute(role_stmt)
        role = role_res.scalar_one_or_none()
        if not role:
            role = Role(name=role_name.upper(), description=f"Role for {role_name.upper()}")
            self.db.add(role)
            await self.db.flush()

        user_role = UserRole(user_id=user.id, role_id=role.id)
        self.db.add(user_role)
        await self.db.commit()

        # Reload with roles
        return await self.get_user_by_id(user.id)  # type: ignore

    async def get_user_by_id(self, user_id: str) -> Optional[User]:
        stmt = (
            select(User)
            .options(selectinload(User.roles).selectinload(UserRole.role))
            .where(User.id == user_id)
        )
        res = await self.db.execute(stmt)
        return res.scalar_one_or_none()

    def generate_tokens(self, user: User) -> Tuple[str, str, int]:
        role_names = [ur.role.name for ur in user.roles if ur.role]
        token_data = {
            "sub": str(user.id),
            "email": user.email,
            "roles": role_names,
        }
        access_token = create_access_token(token_data)
        refresh_token = create_refresh_token(token_data)
        expires_in = settings.ACCESS_TOKEN_EXPIRE_MINUTES * 60
        return access_token, refresh_token, expires_in

    async def refresh_tokens(self, refresh_token: str) -> Tuple[str, str, int]:
        payload = decode_token(refresh_token)
        if payload.get("type") != "refresh":
            raise ValueError("Invalid refresh token type")
        user_id = payload.get("sub")
        if not user_id:
            raise ValueError("Token missing user subject")
        user = await self.get_user_by_id(user_id)
        if not user or not user.is_active:
            raise ValueError("User inactive or not found")
        return self.generate_tokens(user)
