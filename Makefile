.PHONY: build push build-tag-and-push helm-package helm-distribute helm-deploy helm-undeploy all

help: ## This help dialog.
	@IFS=$$'\n' ; \
	help_lines=(`fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##/:/'`); \
	printf "%-30s %s\n" "DevOps console for Project PiPHP" ; \
	printf "%-30s %s\n" "=================================" ; \
	printf "%-30s %s\n" "" ; \
	printf "%-30s %s\n" "Target" "Help" ; \
	printf "%-30s %s\n" "------" "----" ; \
	for help_line in $${help_lines[@]}; do \
        IFS=$$':' ; \
        help_split=($$help_line) ; \
        help_command=`echo $${help_split[0]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        help_info=`echo $${help_split[2]} | sed -e 's/^ *//' -e 's/ *$$//'` ; \
        printf '\033[36m'; \
        printf "%-30s %s" $$help_command ; \
        printf '\033[0m'; \
        printf "%s\n" $$help_info; \
    done

%:      # thanks to chakrit
	@:    # thanks to Wi.lliam Pursell

build: ## Build docker image on Docker for Mac and save in images/
	cd src && docker build  -t piphp  .
	docker save --output out/images/piphp.tar piphp

push: ## Push to private docker registry via router
	cd ansible && ansible-playbook push.yml

build-tag-and-push: ## Build docker image on Docker for Mac, tag and push directly
	cd src && docker build  -t piphp  .
	docker tag piphp ceil-router.dev:5001/helmuthva/piphp
	docker push ceil-router.dev:5001/helmuthva/piphp

helm-package: ## Package helm chart
	helm package piphp -d out/chart

helm-distribute: ## Distribute helm chart
	cp out/chart/* /Projects/helm/
	cd /Projects/helm && git add . && git commit -am "piphp chart" && git push || true

helm-deploy: ## Deploy
	helm repo add helmuthva https://helmuthva.github.io/helm
	helm install helmuthva/piphp --name piphp

helm-undeploy: ## Delete deployment
	helm delete --purge piphp || true

all: build-tag-and-push helm-package helm-distribute undeploy deploy ##  Build, tag, push, package helm, distribute helm, undeploy, deploy

