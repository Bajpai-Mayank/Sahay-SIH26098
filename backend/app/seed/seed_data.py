import asyncio
from datetime import datetime, timezone
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.db.session import AsyncSessionLocal, engine
from app.db.base import Base
import app.models  # Register all models
from app.models.role import Role, RoleName, UserRole
from app.models.user import User
from app.models.case import Case, CaseAssignment
from app.models.consent import Consent
from app.models.checkin import Checkin
from app.models.assessment import Assessment, AssessmentFeature, SupportPriorityEvent
from app.models.service_directory import ServiceDirectory
from app.security.password import get_password_hash


async def seed_database():
    print("Beginning synthetic demo seed...")

    # Ensure tables exist
    async with engine.begin() as conn:
        await conn.run_sync(Base.metadata.create_all)

    async with AsyncSessionLocal() as db:
        # 1. Seed Roles
        roles_data = [
            (RoleName.VICTIM.value, "Victim / Citizen seeking support and check-ins"),
            (RoleName.COUNSELLOR.value, "Professional caseworker or mental health counsellor"),
            (RoleName.DISTRICT_ADMIN.value, "District administrative supervisor"),
            (RoleName.STATE_ADMIN.value, "State department coordinator"),
            (RoleName.NATIONAL_ADMIN.value, "National oversight administrator"),
        ]
        role_map = {}
        for r_name, r_desc in roles_data:
            stmt = select(Role).where(Role.name == r_name)
            res = await db.execute(stmt)
            role_obj = res.scalar_one_or_none()
            if not role_obj:
                role_obj = Role(name=r_name, description=r_desc)
                db.add(role_obj)
                await db.flush()
            role_map[r_name] = role_obj

        # 2. Seed Demo Users
        users_data = [
            {
                "email": "counsellor@sahay.org",
                "password": get_password_hash("Demo1234!"),
                "full_name": "Priya Sharma (Demo Counsellor)",
                "phone_number": "+919876543210",
                "district": "Central Administrative Zone",
                "state": "Delhi NCR",
                "role": RoleName.COUNSELLOR.value,
            },
            {
                "email": "victim@sahay.org",
                "password": get_password_hash("Demo1234!"),
                "full_name": "Ananya Das (Demo Case Subject)",
                "phone_number": "+919876543211",
                "district": "Central Administrative Zone",
                "state": "Delhi NCR",
                "role": RoleName.VICTIM.value,
            },
            {
                "email": "admin@sahay.org",
                "password": get_password_hash("Demo1234!"),
                "full_name": "Rajesh Verma (Demo District Lead)",
                "phone_number": "+919876543212",
                "district": "Central Administrative Zone",
                "state": "Delhi NCR",
                "role": RoleName.DISTRICT_ADMIN.value,
            },
        ]

        user_map = {}
        for u in users_data:
            stmt = select(User).where(User.email == u["email"])
            res = await db.execute(stmt)
            user_obj = res.scalar_one_or_none()
            if not user_obj:
                user_obj = User(
                    email=u["email"],
                    password_hash=u["password"],
                    full_name=u["full_name"],
                    phone=u["phone_number"],
                    district=u["district"],
                    state=u["state"],
                    is_active=True,
                    is_verified=True,
                )
                db.add(user_obj)
                await db.flush()

                user_role = UserRole(user_id=user_obj.id, role_id=role_map[u["role"]].id)
                db.add(user_role)
                await db.flush()
            user_map[u["email"]] = user_obj

        # 3. Seed Demo Case: CASE-1042
        case_stmt = select(Case).where(Case.case_number == "CASE-1042")
        case_res = await db.execute(case_stmt)
        demo_case = case_res.scalar_one_or_none()
        if not demo_case:
            victim_user = user_map["victim@sahay.org"]
            counsellor_user = user_map["counsellor@sahay.org"]

            demo_case = Case(
                case_number="CASE-1042",
                victim_id=str(victim_user.id),
                status="active",
                district="Central Administrative Zone",
                state="Delhi NCR",
            )
            db.add(demo_case)
            await db.flush()

            # Case Assignment
            assignment = CaseAssignment(
                case_id=demo_case.id,
                counsellor_id=str(counsellor_user.id),
                is_primary=True,
            )
            db.add(assignment)

            # Consents
            for c_type in ["data_collection", "voice_recording", "ai_analysis"]:
                c = Consent(
                    case_id=demo_case.id,
                    consent_type=c_type,
                    granted=True,
                    granted_at=datetime.now(timezone.utc),
                    consent_version="1.0",
                )
                db.add(c)

            # Check-in 1 (Baseline)
            checkin1 = Checkin(
                case_id=demo_case.id,
                checkin_type="scheduled",
                responses={"sleep": "ok", "appetite": "normal", "social_contact": "family"},
                mood_rating=3,
                distress_level=4,
                notes="Introductory check-in. Feeling slightly anxious but managing with daily routines.",
                idempotency_key="demo-checkin-1042-001",
            )
            db.add(checkin1)
            await db.flush()

            # Assessment 1
            assessment1 = Assessment(
                case_id=demo_case.id,
                checkin_id=checkin1.id,
                assessment_type="automated",
                priority="LOW",
                score=25,
                confidence=0.92,
                trend="STABLE",
                reasons=["Baseline intake completed", "Mild self-reported distress within standard adaptation range"],
                requires_human_review=False,
                ai_provider="mock",
                ai_model="mock-rules-v1",
            )
            db.add(assessment1)
            await db.flush()

            # Assessment features
            feat1 = AssessmentFeature(
                assessment_id=assessment1.id,
                feature_name="baseline_distress",
                feature_value=0.4,
                source="checkin",
                evidence="Distress rating 4/10",
            )
            db.add(feat1)

            event1 = SupportPriorityEvent(
                case_id=demo_case.id,
                assessment_id=assessment1.id,
                priority="LOW",
                score=25,
                trend="STABLE",
                snapshot={"score": 25, "priority": "LOW"},
            )
            db.add(event1)

        # 4. Seed Service Directory
        service_stmt = select(ServiceDirectory).limit(1)
        if not (await db.execute(service_stmt)).scalar_one_or_none():
            services = [
                ServiceDirectory(
                    name="Central One-Stop Crisis Center (OSC)",
                    service_type="Emergency Shelter & Medical",
                    district="Central Administrative Zone",
                    state="Delhi NCR",
                    phone="011-2338-0000",
                    is_active=True,
                    metadata_json={"available_capacity": 6, "total_capacity": 20},
                ),
                ServiceDirectory(
                    name="District Legal Services Authority (DLSA) Helpdesk",
                    service_type="Free Legal Aid & Counsel",
                    district="Central Administrative Zone",
                    state="Delhi NCR",
                    phone="15100",
                    is_active=True,
                    metadata_json={"available_capacity": 12, "total_capacity": 15},
                ),
                ServiceDirectory(
                    name="Tele-MANAS Mental Health Support Hub",
                    service_type="Psychosocial Tele-Counselling",
                    district="Central Administrative Zone",
                    state="Delhi NCR",
                    phone="14416",
                    is_active=True,
                    metadata_json={"available_capacity": 30, "total_capacity": 30},
                ),
            ]
            db.add_all(services)

        await db.commit()
        print("Demo seed completed successfully.")


if __name__ == "__main__":
    asyncio.run(seed_database())
