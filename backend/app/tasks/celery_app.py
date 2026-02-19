# Celery configuration
from celery import Celery
from app.core.config import settings

celery_app = Celery(
    "pitstop",
    broker=settings.REDIS_URL,
    backend=settings.REDIS_URL,
)

celery_app.conf.update(
    task_serializer="json",
    accept_content=["json"],
    result_serializer="json",
    timezone="UTC",
    enable_utc=True,
)

# Import tasks
# from app.tasks import example_task
