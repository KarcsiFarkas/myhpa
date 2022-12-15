all: help

help:
	@echo ----------------------------------
	@echo PHP-APACHE DEPLOYMENT COMMANDS
	@echo ----------------------------------
	@echo make image 	- build and upload docker image to minikube environment
	@echo make apply 	- deploy php-myapache and expose service, start hpa
	@echo make hpa 	- get all hpas
	@echo make delete	- uninstall php-myapache deployment and service and hpa
	@echo make svc	- get all services
	@echo make deploy	- get all deployments
	@echo make pods	- get all pods
	@echo make deploydesc	- describe deployments
	@echo make poddesc	- describe pods
	@echo make svcdesc	- describe services
	@echo make hpadesc	- describe hpa
	@echo make run	- testing

delete:
	kubectl delete service php-service
	kubectl delete deployment php-myapache
	kubectl delete hpa php-myapache

image:
	eval $(minikube docker-env)
	docker image prune -f
	docker build -t registry.k8s.io/hpa-example .

apply:
	kubectl apply -f hpa-example/php-myapache.yaml
	kubectl get services | grep php-service
	kubectl apply -f hpa-example/hpa-myapache.yaml
	kubectl get hpa

deploy:
	kubectl get deployments -A

svc:
	kubectl get svc -A

pods:
	kubectl get po -A

hpa:
	kubectl get hpa -A

deploydesc:
	kubectl describe deployment -n=default

poddesc:
	kubectl describe pods -n=default

svcdesc:
	kubectl describe svc -n=default

hpadesc:
	kubectl describe hpa -n=default

run:
	ENDPOINT=http://10.100.94.241:5005/metrics k6 run -o influxdb=http://localhost:8086/k6 performance-test.js
