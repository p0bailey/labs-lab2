.PHONY: deploy vpc_ec2_deploy tgw_deploy destroy vpc_ec2_destroy tgw_destroy help

help:
	@echo "Available targets:"
	@echo "  deploy         - Deploy resources by entering vpc_ec2 and tgw directories and running 'make init', 'make plan', and 'make apply'."
	@echo "  destroy        - Destroy resources by entering vpc_ec2 and tgw directories and running 'make destroy'."
	@echo "  help           - Display this help message."


# Top-level target for deployment
deploy: vpc_ec2_deploy tgw_deploy
destroy: tgw_destroy vpc_ec2_destroy


# Target for operations in the vpc_ec2 directory
vpc_ec2_deploy:
	cd vpc_ec2 && $(MAKE) init && $(MAKE) plan && $(MAKE) apply

# Target for operations in the tgw directory
tgw_deploy:
	cd tgw && $(MAKE) init && $(MAKE) plan && $(MAKE) apply

# Top-level target for destruction
destroy: vpc_ec2_destroy tgw_destroy

# Target for destruction in the vpc_ec2 directory
vpc_ec2_destroy:
	cd vpc_ec2 && $(MAKE) destroy

# Target for destruction in the tgw directory
tgw_destroy:
	cd tgw && $(MAKE) destroy

