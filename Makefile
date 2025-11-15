AWS_PROFILE:=devops

awslogin:
	aws sso login --profile $(AWS_PROFILE)

tfinit:
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=module/terraform init

tfplan:
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=module/terraform plan

tfapply:
	AWS_PROFILE=$(AWS_PROFILE) terraform -chdir=module/terraform apply --auto-approve
