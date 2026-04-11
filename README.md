# tf-demo-hashi

HashiCorp Terraform demo repo showcasing HCP Terraform integration with GitHub Actions.

## What This Demo Shows

| Feature | How It's Triggered |
|---|---|
| Speculative Plan | Open a Pull Request against `main` |
| Plan posted as PR comment | Automatically via GitHub Actions |
| Sentinel policy check | Runs as part of every plan in HCP Terraform |
| Apply on merge | Merge PR to `main` triggers apply |
| Variable sets | Environment and AWS credentials set in HCP Terraform org |

---

## Setup Checklist

### 1. HCP Terraform

- [ ] Create a free org at https://app.terraform.io
- [ ] Create a workspace named `tf-demo-hashi`
  - Execution mode: **Remote**
  - VCS connection: **None** (API-driven via GitHub Actions)
- [ ] Create a **Variable Set** at the org level with:
  - `AWS_ACCESS_KEY_ID` (Environment, Sensitive)
  - `AWS_SECRET_ACCESS_KEY` (Environment, Sensitive)
  - `AWS_DEFAULT_REGION` (Environment) = `us-east-1`
- [ ] Add Terraform variables to the workspace:
  - `environment` = `dev`
  - `region` = `us-east-1`
  - `owner` = your name or team
- [ ] Generate a **User API Token** at https://app.terraform.io/app/settings/tokens

### 2. GitHub Repository

- [ ] Fork or clone this repo
- [ ] Add the following GitHub Actions secret:
  - `TF_API_TOKEN` = your HCP Terraform API token
- [ ] Update `main.tf` cloud block:
  ```hcl
  cloud {
    organization = "YOUR_ORG_NAME"   # <-- replace this
    workspaces {
      name = "tf-demo-hashi"
    }
  }
  ```

### 3. Sentinel Policy Set (Optional but recommended for the demo)

- [ ] In HCP Terraform, go to **Settings > Policy Sets**
- [ ] Create a new policy set
  - Connect it to your repo, path: `sentinel/`
  - Apply to workspace: `tf-demo-hashi`
- [ ] Policies will automatically enforce on every plan

---

## Demo Flow

### Part 1: PR Triggers Speculative Plan

1. Create a feature branch: `git checkout -b feature/update-instance-type`
2. Make a small change (e.g., update a tag value in `variables.tf`)
3. Open a Pull Request against `main`
4. Watch the GitHub Actions workflow trigger
5. See the plan output posted as a PR comment
6. In HCP Terraform, show the speculative plan run in the workspace

### Part 2: Sentinel Policy in Action (Best demo moment)

1. On your feature branch, change `instance_type` default to `t3.large` in `variables.tf`
2. Open a PR - the plan runs and Sentinel's `restrict-instance-types` policy blocks it
3. Show the policy failure in HCP Terraform and in the PR check
4. Change it back to `t3.micro` - the policy passes
5. Talk through the difference between `soft-mandatory` (tags) and `hard-mandatory` (instance type)

### Part 3: Merge to Main Triggers Apply

1. Merge the PR
2. The `terraform-apply.yml` workflow triggers
3. Show the apply running in HCP Terraform with run history
4. Point out state is stored and versioned in HCP Terraform

### Part 4: Variable Sets

1. In HCP Terraform, navigate to your org's Variable Sets
2. Show the AWS credentials variable set applied globally
3. Show workspace-level variables (environment, region)
4. Explain: this replaces everyone managing their own tfvars files

---

## Repo Structure

```
tf-demo-hashi/
├── .github/
│   └── workflows/
│       ├── terraform-plan.yml     # Runs on PR - speculative plan + PR comment
│       └── terraform-apply.yml   # Runs on merge to main - full apply
├── sentinel/
│   ├── sentinel.hcl               # Policy set config
│   ├── enforce-required-tags.sentinel   # soft-mandatory
│   └── restrict-instance-types.sentinel # hard-mandatory
├── main.tf                        # EC2, security group, AMI data source
├── variables.tf                   # All input variables with validation
├── outputs.tf                     # Instance ID, IP, web URL
└── user_data.sh                   # Web server bootstrap script
```

---

## Intentional Policy Failure (Demo Tip)

To trigger the `restrict-instance-types` hard-mandatory policy failure live:

```hcl
# In variables.tf, temporarily change the default to:
default = "t3.large"
```

Open a PR with this change. The plan will run, Sentinel will block it, and the PR check will fail. This is the most impactful moment in the demo because it shows guardrails working in the actual PR workflow the engineers care about.
