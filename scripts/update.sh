terraform plan --var-file env/$1-bfp-vars-def.tfvars
terraform apply --var-file env/$1-bfp-vars-def.tfvars
