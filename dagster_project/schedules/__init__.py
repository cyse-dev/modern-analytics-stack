from dagster import schedule, DefaultScheduleStatus

from ..jobs import daily_analytics_job


@schedule(
    job=daily_analytics_job,
    cron_schedule="0 2 * * *",  # Daily at 2 AM
    default_status=DefaultScheduleStatus.RUNNING,
)
def daily_schedule(context):
    """Schedule for daily analytics pipeline"""
    return {
        "ops": {
            "raw_user_events": {
                "config": {
                    "execution_date": context.scheduled_execution_time.strftime("%Y-%m-%d")
                }
            }
        }
    }


# Export schedules
__all__ = ["daily_schedule"]