from urllib.parse import parse_qs, urlparse

import pytest
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker
from sqlalchemy.pool import StaticPool

from app.api.v1.endpoints import auth as auth_endpoint
from app.db.session import Base, get_db
from app.main import app
from app.services import auth as auth_module


@pytest.fixture()
def client():
    engine = create_engine(
        "sqlite://",
        connect_args={"check_same_thread": False},
        poolclass=StaticPool,
    )
    TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
    Base.metadata.create_all(bind=engine)

    def override_get_db():
        db = TestingSessionLocal()
        try:
            yield db
        finally:
            db.close()

    app.dependency_overrides[get_db] = override_get_db
    with TestClient(app) as test_client:
        yield test_client
    app.dependency_overrides.clear()
    Base.metadata.drop_all(bind=engine)


def test_register_login_me_and_refresh(client):
    register_response = client.post(
        "/api/v1/auth/register",
        json={"email": "User@Example.com", "password": "password123"},
    )
    assert register_response.status_code == 201
    register_body = register_response.json()
    assert register_body["email"] == "user@example.com"
    assert register_body["is_new_user"] is True
    assert register_body["access_token"]
    assert register_body["refresh_token"]

    me_response = client.get(
        "/api/v1/auth/me",
        headers={"Authorization": f"Bearer {register_body['access_token']}"},
    )
    assert me_response.status_code == 200
    assert me_response.json()["email"] == "user@example.com"

    login_response = client.post(
        "/api/v1/auth/login",
        json={"email": "user@example.com", "password": "password123"},
    )
    assert login_response.status_code == 200
    assert login_response.json()["is_new_user"] is False

    refresh_response = client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": register_body["refresh_token"]},
    )
    assert refresh_response.status_code == 200
    rotated_token = refresh_response.json()["refresh_token"]
    assert rotated_token != register_body["refresh_token"]

    reused_response = client.post(
        "/api/v1/auth/refresh",
        json={"refresh_token": register_body["refresh_token"]},
    )
    assert reused_response.status_code == 401


def test_register_rejects_duplicate_email(client):
    body = {"email": "user@example.com", "password": "password123"}
    assert client.post("/api/v1/auth/register", json=body).status_code == 201
    assert client.post("/api/v1/auth/register", json=body).status_code == 409


def test_login_rejects_invalid_password(client):
    client.post(
        "/api/v1/auth/register",
        json={"email": "user@example.com", "password": "password123"},
    )
    response = client.post(
        "/api/v1/auth/login", json={"email": "user@example.com", "password": "wrong"}
    )
    assert response.status_code == 401


def test_google_auth_creates_and_reuses_user(client, monkeypatch):
    class FakeGoogleVerifier:
        def verify(self, id_token):
            return {
                "sub": "google-sub-1",
                "email": "google@example.com",
                "email_verified": True,
                "name": "Google User",
            }

    monkeypatch.setattr(auth_endpoint, "google_token_verifier", FakeGoogleVerifier())

    first_response = client.post("/api/v1/auth/google", json={"id_token": "valid"})
    assert first_response.status_code == 200
    assert first_response.json()["is_new_user"] is True
    assert first_response.json()["display_name"] == "Google User"

    second_response = client.post("/api/v1/auth/google", json={"id_token": "valid"})
    assert second_response.status_code == 200
    assert second_response.json()["is_new_user"] is False
    assert second_response.json()["user_id"] == first_response.json()["user_id"]


def test_apple_auth_requires_email_for_new_user(client, monkeypatch):
    class FakeAppleVerifier:
        def verify(self, identity_token):
            return {"sub": "apple-sub-1"}

    monkeypatch.setattr(auth_endpoint, "apple_token_verifier", FakeAppleVerifier())

    response = client.post(
        "/api/v1/auth/apple",
        json={"identity_token": "valid", "authorization_code": "code"},
    )
    assert response.status_code == 400


def test_apple_auth_creates_user(client, monkeypatch):
    class FakeAppleVerifier:
        def verify(self, identity_token):
            return {"sub": "apple-sub-1", "email": "apple@example.com"}

    monkeypatch.setattr(auth_endpoint, "apple_token_verifier", FakeAppleVerifier())

    response = client.post(
        "/api/v1/auth/apple",
        json={"identity_token": "valid", "authorization_code": "code"},
    )
    assert response.status_code == 200
    assert response.json()["email"] == "apple@example.com"
    assert response.json()["is_new_user"] is True


def test_forgot_and_reset_password(client, monkeypatch):
    sent_urls = []

    class FakeEmailService:
        def send_password_reset_email(self, *, to_email, reset_url):
            sent_urls.append(reset_url)
            return True

    monkeypatch.setattr(auth_module, "email_service", FakeEmailService())

    client.post(
        "/api/v1/auth/register",
        json={"email": "user@example.com", "password": "password123"},
    )
    forgot_response = client.post(
        "/api/v1/auth/forgot-password", json={"email": "user@example.com"}
    )
    assert forgot_response.status_code == 200
    assert sent_urls

    token = parse_qs(urlparse(sent_urls[0]).query)["token"][0]
    reset_response = client.post(
        "/api/v1/auth/reset-password",
        json={"token": token, "password": "newpassword123"},
    )
    assert reset_response.status_code == 200

    reused_response = client.post(
        "/api/v1/auth/reset-password",
        json={"token": token, "password": "anotherpassword123"},
    )
    assert reused_response.status_code == 400

    old_login = client.post(
        "/api/v1/auth/login",
        json={"email": "user@example.com", "password": "password123"},
    )
    assert old_login.status_code == 401

    new_login = client.post(
        "/api/v1/auth/login",
        json={"email": "user@example.com", "password": "newpassword123"},
    )
    assert new_login.status_code == 200
