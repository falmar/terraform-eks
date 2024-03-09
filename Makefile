.PHONY: apply_bootstrap_with_addon apply_bootstrap deploy_critical deploy_components apply_default

bootstrap:
	terraform apply -var bootstrap=true -var allow_addons=true
	terraform apply -var bootstrap=true -auto-approve

bootstrap_destroy:
	terraform apply -var bootstrap=true

deploy_critical: secrets/kubeconfig/main
	terraform apply -var critical_apps=2 -var allow_nodes=false

deploy_components: secrets/kubeconfig/main
	terraform apply -var critical_apps=1 -var allow_nodes=false

deploy_all: bootstrap secrets/kubeconfig/main deploy_critical deploy_components deploy
	@echo "Deployed all components"

deploy: secrets/kubeconfig/main
	terraform apply -var allow_nodes=false


destroy:
	terraform destroy -var bootstrap=true

clean:
	rm -rf secrets/kubeconfig
