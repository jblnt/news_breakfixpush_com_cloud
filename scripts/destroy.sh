terraform plan --var-file env/$1-bfp-vars-def.tfvars
terraform apply --var-file env/$1-bfp-vars-def.tfvars

export RESET_SG=$(aws ec2 describe-security-groups --filters Name=tag:Name,Values="default" --query 'SecurityGroups[*].GroupId' --output text --profile jblnt | awk '{printf "[\"%s\"]", $1}')

echo $RESET_SG
sed -i "s|\(db_ingress_sgs\) = .*|\1 = ${RESET_SG}|g" env/$1-bfp-vars-def.tfvars
unset RESET_SG

terraform plan --var-file env/$1-bfp-vars-def.tfvars
terraform apply --var-file env/$1-bfp-vars-def.tfvars --auto-approve

terraform destroy --var-file env/$1-bfp-vars-def.tfvars
