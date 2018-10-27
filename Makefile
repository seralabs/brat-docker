.PHONY: image push-local push-gcr deploy-local deploy-staging

TAG:=$(shell git rev-list HEAD --max-count=1 --abbrev-commit)
export TAG

PULL_POLICY:=Always
export PULL_POLICY

DOCKER_REGISTRY_HOSTNAME = gcr.io
GOOGLE_CLOUD_PROJECT = $(GCP_SERA_PROJECT)

DOCKER_IMAGE_PREFIX_GCR:=$(DOCKER_REGISTRY_HOSTNAME)/$(GOOGLE_CLOUD_PROJECT)/
DOCKER_IMAGE_PREFIX_LOCAL:=localhost:5000/

image:
	eval $(minikube docker-env)
	sh build_docker.sh $(TAG)

push-local:
	eval $(minikube docker-env)
	docker tag brat:$(TAG) $(DOCKER_IMAGE_PREFIX_LOCAL)brat:$(TAG)
	docker push $(DOCKER_IMAGE_PREFIX_LOCAL)brat:$(TAG)

push-gcr:
	docker tag brat:$(TAG) $(DOCKER_IMAGE_PREFIX_GCR)brat:$(TAG)
	docker push $(DOCKER_IMAGE_PREFIX_GCR)brat:$(TAG)

deploy-local:
	kubectl config use minikube
	SERA_ENV=minikube REPLICAS=1 DOCKER_IMAGE_PREFIX=$(DOCKER_IMAGE_PREFIX_LOCAL) envsubst < kubernetes/common.yml | kubectl apply --namespace=minikube -f -

deploy-staging:
	kubectl config use staging
	SERA_ENV=staging REPLICAS=1 DOCKER_IMAGE_PREFIX=$(DOCKER_IMAGE_PREFIX_GCR) envsubst < kubernetes/common.yml | kubectl apply --namespace=staging -f -
