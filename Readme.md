#Pre-requisite

- Terraform
- aws cli
- cofngure AWS with your secret
- install and configure infracost: https://www.infracost.io/docs/#quick-start

# Generate infra cot
terraform init
terraform plan -out=tfplan.binary
infracost breakdown --path=tfplan.binary

Note about cost estimate check:  Terraform variables can be set using --terraform-var-file or --terraform-var
infracost breakdown --path .