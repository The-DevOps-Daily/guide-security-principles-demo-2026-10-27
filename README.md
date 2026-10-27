# Security Principles guide: files and test runs

Companion repository for the DevOps Daily guide
[Security Principles](https://devops-daily.com/guides/security-principles):
the CIA triad, defense in depth, least privilege and zero trust, applied to a small ticket shop.

- `part01` to `part04`: every file shown in the guide (Kubernetes manifests, configs, SQL, scripts, IAM policies).
- `scripts/pNN-*.sh`: the commands from each part, in order. `scripts/lib.sh` records each command's output.
- `.github/workflows/guide.yml`: runs everything on Ubuntu 26.04 GitHub-hosted runners (a kind cluster for the
  Kubernetes parts, a fresh VM for the Linux parts) and checks the AWS CLI commands, Terraform files and the
  example deploy workflow for syntax without any cloud credentials.

Everything here is a lab: passwords such as `lab-only-change-me` and the AWS account ID `111122223333` are
placeholders. `part04/deploy-example.yml` is an example and is kept outside `.github/workflows`, so it never runs.

To follow along, clone the repository to `~/security-principles-demo` and start with Part 1 of the guide.
