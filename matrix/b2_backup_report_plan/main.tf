# Backup.4: AWS Backup report plans should be tagged -> no tags
resource "aws_backup_report_plan" "insecure" {
  name = "vp_insecure_backup_report_b2"
  report_delivery_channel {
    s3_bucket_name = "vp-companion-logs-856b2431"
    formats        = ["JSON"]
  }
  report_setting {
    report_template = "BACKUP_JOB_REPORT"
  }
}
