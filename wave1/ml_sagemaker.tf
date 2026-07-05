# SageMaker resources — deferred to Wave 4/5
# SageMaker controls require compute instances (notebook instances, endpoints)
# which have ongoing costs and may need VPC configuration.
#
# Controls to test in Wave 4/5:
#   SageMaker.1 — Notebook instances should not have direct internet access
#   SageMaker.2 — Notebook instances should be launched in a custom VPC
#   SageMaker.3 — Users should not have root access to notebook instances
#   SageMaker.4 — Endpoint production variants should have initial instance count > 1
