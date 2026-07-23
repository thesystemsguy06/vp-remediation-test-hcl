# vp-remediation-test-hcl — ARCHIVED

Superseded by **`vp-e2e-fixtures-hcl`**. Do not add fixtures here.

The fixture roots that used to live on `main` were removed in the 2026-07-23 reset. They
remain in git history if you need to refer to them, but they should not be reused:

* 54 of them declared no `backend "s3"` block, so terraform wrote state to a local disk
  that VectorPlane can never read. No state file means no `AssetProvenance`, which means
  the asset never becomes remediable — and the failure is completely silent.
* State-file rows were registered in VectorPlane pointing at S3 keys terraform never
  wrote, so VP reported them `verified` while monitoring nothing.

The replacement repo enforces the fixture invariants mechanically via
`e2e/fixture_preflight.py`.
