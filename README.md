# Terraform for EKS (WIP)

deploy order:

- terraform apply -var bootstrap=true -var allow_addon=true
- terraform apply -var bootstrap=true 
- terraform apply -var critical_apps=2 -var allow_nodes=false 
- terraform apply -var critical_apps=1 -var allow_nodes=false
- terraform apply

TODO: add allow_addon variable to create then delete default addons
