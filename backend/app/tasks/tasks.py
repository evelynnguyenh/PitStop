# Example Celery task
from app.tasks.celery_app import celery_app
from app.core.logging import logger


@celery_app.task
def example_task(name: str):
    """Example background task."""
    logger.info(f"Processing task for: {name}")
    # Do some work here
    return f"Task completed for {name}"


@celery_app.task
def process_image_upload(image_url: str, post_id: str):
    """Process uploaded image (compression, thumbnail generation, etc.)."""
    logger.info(f"Processing image {image_url} for post {post_id}")
    # TODO: Implement image processing
    pass


@celery_app.task
def send_notification(user_id: str, message: str):
    """Send push notification to user."""
    logger.info(f"Sending notification to user {user_id}")
    # TODO: Implement FCM notification
    pass
