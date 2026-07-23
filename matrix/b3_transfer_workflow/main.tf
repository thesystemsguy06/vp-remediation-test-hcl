resource "aws_transfer_workflow" "vp_b3" {
  steps {
    type = "DELETE"
    delete_step_details {
      name                 = "delstep"
      source_file_location = "$${original.file}"
    }
  }
}
