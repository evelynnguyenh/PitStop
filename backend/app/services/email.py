import smtplib
from email.message import EmailMessage

from app.core.config import settings


class EmailService:
    def send_password_reset_email(self, *, to_email: str, reset_url: str) -> bool:
        if not settings.SMTP_HOST:
            return False

        message = EmailMessage()
        message["Subject"] = "Reset your PitStop password"
        message["From"] = settings.SMTP_FROM_EMAIL
        message["To"] = to_email
        message.set_content(
            "Use this link to reset your PitStop password:\n\n"
            f"{reset_url}\n\n"
            "If you did not request this, you can ignore this email."
        )

        with smtplib.SMTP(settings.SMTP_HOST, settings.SMTP_PORT, timeout=10) as smtp:
            if settings.SMTP_USE_TLS:
                smtp.starttls()
            if settings.SMTP_USERNAME:
                smtp.login(settings.SMTP_USERNAME, settings.SMTP_PASSWORD)
            smtp.send_message(message)
        return True


email_service = EmailService()
