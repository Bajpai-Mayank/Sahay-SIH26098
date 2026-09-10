import base64
import hashlib
import hmac
import json
import time
from datetime import datetime, timedelta, timezone
from typing import Any, Dict, Optional

from app.config import get_settings

settings = get_settings()

try:
    from jose import JWTError, jwt  # type: ignore
    HAS_JOSE = True
except ImportError:
    HAS_JOSE = False
    JWTError = Exception


def create_access_token(
    data: Dict[str, Any], expires_delta: Optional[timedelta] = None
) -> str:
    """Create a signed JWT access token."""
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES)
    
    to_encode.update({
        "exp": int(expire.timestamp()),
        "iat": int(now.timestamp()),
        "type": "access",
    })

    if HAS_JOSE:
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

    # Standard fallback HMAC-SHA256 JWT encoding
    header = {"alg": "HS256", "typ": "JWT"}
    b64_header = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip("=")
    b64_payload = base64.urlsafe_b64encode(json.dumps(to_encode).encode()).decode().rstrip("=")
    signing_input = f"{b64_header}.{b64_payload}".encode()
    signature = hmac.new(settings.JWT_SECRET_KEY.encode(), signing_input, hashlib.sha256).digest()
    b64_sig = base64.urlsafe_b64encode(signature).decode().rstrip("=")
    return f"{b64_header}.{b64_payload}.{b64_sig}"


def create_refresh_token(
    data: Dict[str, Any], expires_delta: Optional[timedelta] = None
) -> str:
    """Create a signed JWT refresh token."""
    to_encode = data.copy()
    now = datetime.now(timezone.utc)
    if expires_delta:
        expire = now + expires_delta
    else:
        expire = now + timedelta(days=settings.REFRESH_TOKEN_EXPIRE_DAYS)
    
    to_encode.update({
        "exp": int(expire.timestamp()),
        "iat": int(now.timestamp()),
        "type": "refresh",
    })

    if HAS_JOSE:
        return jwt.encode(to_encode, settings.JWT_SECRET_KEY, algorithm=settings.JWT_ALGORITHM)

    header = {"alg": "HS256", "typ": "JWT"}
    b64_header = base64.urlsafe_b64encode(json.dumps(header).encode()).decode().rstrip("=")
    b64_payload = base64.urlsafe_b64encode(json.dumps(to_encode).encode()).decode().rstrip("=")
    signing_input = f"{b64_header}.{b64_payload}".encode()
    signature = hmac.new(settings.JWT_SECRET_KEY.encode(), signing_input, hashlib.sha256).digest()
    b64_sig = base64.urlsafe_b64encode(signature).decode().rstrip("=")
    return f"{b64_header}.{b64_payload}.{b64_sig}"


def decode_token(token: str) -> Dict[str, Any]:
    """Decode and validate a signed JWT token."""
    if HAS_JOSE:
        return jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )

    # Fallback validation
    parts = token.split(".")
    if len(parts) != 3:
        raise ValueError("Invalid token structure")
    
    b64_header, b64_payload, b64_sig = parts
    signing_input = f"{b64_header}.{b64_payload}".encode()
    expected_sig = hmac.new(settings.JWT_SECRET_KEY.encode(), signing_input, hashlib.sha256).digest()
    
    # Pad base64 signature
    padding = "=" * ((4 - len(b64_sig) % 4) % 4)
    given_sig = base64.urlsafe_b64decode(b64_sig + padding)
    if not hmac.compare_digest(expected_sig, given_sig):
        raise ValueError("Signature verification failed")

    # Pad payload
    payload_padding = "=" * ((4 - len(b64_payload) % 4) % 4)
    payload_bytes = base64.urlsafe_b64decode(b64_payload + payload_padding)
    payload = json.loads(payload_bytes)

    # Validate expiration
    exp = payload.get("exp")
    if exp and int(time.time()) > int(exp):
        raise ValueError("Token has expired")

    return payload
