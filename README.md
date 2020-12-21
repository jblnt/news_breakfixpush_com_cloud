# news.breakfixpush.com - AWS
Configuration files used to initalize and mange the cloud infustructure on AWS using Terraform.

Currently 2 files are also neeeded. 
One terraform variables file and one environment file for the container which performs data gathering (currently not in this public repo).

## Inital Setup
Initial setup can be done by running the __init.sh__ file from the scripts folder and passing the environment as an argument (prod,dev,testing) in the base directory. The environment specified will created resources of the same name.

```
sh scripts/init.sh prod 
```

## Updating Infustructure
After changes are made to the terraform files they can be applied by running the __update.sh__ file with the desired environment as an argument:

```
sh scripts/update.sh prod
```

## Destroying Infustructure 
When its time to destory the created resource in AWS run the __destroy.sh__ file with the desired environment as an argument:

```
sh scripts/destroy.sh prod
```
