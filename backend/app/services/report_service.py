import boto3
import os
from datetime import datetime

def upload_daily_report(report_text: str):
    """
    Uploads a simple text report to S3.
    This helps demonstrate AWS S3 integration for my project.
    """
    bucket = os.getenv("S3_REPORT_BUCKET")
    region = os.getenv("AWS_REGION", "eu-central-1")

    if not bucket:
        return {"status": "ERROR", "message": "S3 bucket not configured"}

    filename = f"reports/report_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}.txt"

    try:
        s3 = boto3.client("s3", region_name=region)
        s3.put_object(
            Bucket=bucket,
            Key=filename,
            Body=report_text.encode("utf-8"),
            ContentType="text/plain"
        )
        return {"status": "OK", "message": "Report uploaded", "file": filename}

    except Exception as e:
        return {"status": "ERROR", "message": str(e)}
