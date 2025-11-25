from flask import Blueprint, jsonify
from ..services.report_service import upload_daily_report

report_bp = Blueprint("reports", __name__)

@report_bp.route("/report/upload", methods=["POST"])
def upload_report():
    """Upload a test report to S3 from my GroceryMate application."""
    result = upload_daily_report("This is my GroceryMate daily report.")
    return jsonify(result)
