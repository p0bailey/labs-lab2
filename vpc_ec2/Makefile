COMMAND = terraform

.PHONY: all

all:
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'


init: ## Terraform init
	$(COMMAND) init 

plan: ## Terraform init
	$(COMMAND)  plan  -var-file=../terraform.tfvars
	
apply: ## Terraform init
	$(COMMAND)  apply -auto-approve -var-file=../terraform.tfvars

refresh:  ## Terraform refresh
	$(COMMAND)  refresh  -var-file=../terraform.tfvars

destroy: ## Destroy
	$(COMMAND) destroy  -auto-approve  -var-file=../terraform.tfvars

