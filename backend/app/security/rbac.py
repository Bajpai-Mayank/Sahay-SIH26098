import uuid
from typing import Callable, List, Optional

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import selectinload

from app.db.session import get_db
from app.models.role import RoleName
from app.models.user import User
from app.security.jwt import decode_token

# Bearer scheme that extracts the Authorization header
security_bearer = HTTPBearer(auto_error=False)


async def get_current_user_optional(
    credentials: Optional[HTTPAuthorizationCredentials] = Depends(security_bearer),
    db: AsyncSession = Depends(get_db),
) -> Optional[User]:
    """Extract current user from Bearer token if present, otherwise return None."""
    if not credentials or not credentials.credentials:
        return None

    token = credentials.credentials
    try:
        payload = decode_token(token)
        user_id_str = payload.get("sub")
        if not user_id_str:
            return None
        user_id = str(user_id_str)
    except Exception:
        return None

    from app.models.role import UserRole
    stmt = (
        select(User)
        .options(selectinload(User.roles).selectinload(UserRole.role))
        .where(User.id == user_id, User.is_active.is_(True))
    )
    result = await db.execute(stmt)
    return result.scalar_one_or_none()


async def get_current_user(
    user: Optional[User] = Depends(get_current_user_optional),
) -> User:
    """Dependency that requires an authenticated, active user."""
    if not user:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication credentials were not provided or are invalid",
            headers={"WWW-Authenticate": "Bearer"},
        )
    return user


def require_role(*required_roles: str) -> Callable:
    """
    Dependency factory that checks whether the authenticated user has at least
    one of the specified roles, or is a NATIONAL_ADMIN / superuser.
    """
    async def role_checker(current_user: User = Depends(get_current_user)) -> User:
        user_role_names = [ur.role.name for ur in current_user.roles if ur.role]

        # National Admin has superuser override access
        if RoleName.NATIONAL_ADMIN.value in user_role_names:
            return current_user

        # Check if user has any required role
        for req in required_roles:
            if req in user_role_names:
                return current_user

        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail=f"Access forbidden: requires one of the following roles: {list(required_roles)}",
        )

    return role_checker


async def check_case_access(case_id: str, user: User, db: AsyncSession) -> bool:
    """
    Object-level authorization check:
    - National / State / District admins have wide access.
    - Counsellors can only access cases assigned to them.
    - Victims can only access their own case.
    """
    user_roles = [ur.role.name for ur in user.roles if ur.role]
    if (
        RoleName.NATIONAL_ADMIN.value in user_roles
        or RoleName.STATE_ADMIN.value in user_roles
        or RoleName.DISTRICT_ADMIN.value in user_roles
    ):
        return True

    # Case imports
    from app.models.case import Case, CaseAssignment

    case_stmt = select(Case).where(Case.id == str(case_id))
    case_res = await db.execute(case_stmt)
    case = case_res.scalar_one_or_none()
    if not case:
        return False

    if RoleName.VICTIM.value in user_roles:
        return case.victim_id == str(user.id)

    if RoleName.COUNSELLOR.value in user_roles:
        assign_stmt = select(CaseAssignment).where(
            CaseAssignment.case_id == str(case_id),
            CaseAssignment.counsellor_id == str(user.id),
            CaseAssignment.unassigned_at.is_(None),
        )
        assign_res = await db.execute(assign_stmt)
        return assign_res.scalar_one_or_none() is not None

    return False
