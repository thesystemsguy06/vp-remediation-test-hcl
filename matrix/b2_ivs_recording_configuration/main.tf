# IVS.2: IVS recording configurations should be tagged -> no tags
resource "aws_ivs_recording_configuration" "insecure" {
  name = "vp-insecure-ivs-rec-b2"
  destination_configuration {
    s3 {
      bucket_name = "vp-companion-logs-856b2431"
    }
  }
}
