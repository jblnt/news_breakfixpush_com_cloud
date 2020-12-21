terraform init

terraform plan --var-file env/$1-bfp-vars-def.tfvars

terraform apply --var-file env/$1-bfp-vars-def.tfvars

export bfp_sg=$(aws ec2 describe-security-groups --filters Name=tag:Name,Values="bfp-$1-django-env","bfp-$1-scraper-cluster-sg" --query 'SecurityGroups[*].GroupId' --output text --profile jblnt | awk '{printf "[\"%s\",\"%s\"]\n", $1, $2}')

echo $bfp_sg

sed -i "s|\(db_ingress_sgs\) = .*|\1 = ${bfp_sg}|g" env/$1-bfp-vars-def.tfvars

unset bfp_sg

terraform plan --var-file env/$1-bfp-vars-def.tfvars

terraform apply --var-file env/$1-bfp-vars-def.tfvars
