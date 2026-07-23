resource "aws_batch_scheduling_policy" "sp" {
  name = "vp-b5-sched-72092"
  fair_share_policy {
    compute_reservation = 1
    share_decay_seconds = 3600
  }
}
