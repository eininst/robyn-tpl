
project = robyn-tpl

build:
	docker build -f Dockerfile -t robyn-tpl .



build-dev:
	docker build -f dev/Dockerfile -t qy .

build-nginx-dev:
	docker build -f nginx/DockerfileDev -t nginx .

run-nginx:
	docker run -it --rm -v $(CURDIR)/nginx:/etc/nginx \
	-v $(CURDIR)/nginx/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf \
	-v $(CURDIR)/nginx/default.conf:/usr/local/openresty/nginx/conf/nginx.conf.default \
	--net=bridge -p 80:80 nginx

flush:
	docker run --rm -v $(CURDIR)/requirements.txt:/app/requirements.txt \
	qy:latest bash -c "pip freeze > requirements.txt"


api:
	docker run -e WSGI="/app/api/wsgi.py" -e PROCESSES=8 -e THREADS=32 -e DEBUG=0 \
 	-it --rm -v $(CURDIR):/app --net=bridge -p 8080:8080 qy-api:latest tail -f /dev/null


push:
	docker tag python:3.13-ARM $(registry_mirrors)/$(namespace)/python:3.13-ARM
	docker push $(registry_mirrors)/$(namespace)/python:3.13-ARM


init:
	sh $(CURDIR)/scripts/swarm.sh

deploy:
	docker stack deploy --with-registry-auth -c deployments/$(yml).yml $(group)

update:
	docker service update --force --stop-grace-period 20s --image \
	`sh $(CURDIR)/scripts/yaml.sh $(CURDIR)/deployments/${yml}.yml services_$(app)_image` \
	$(group)_${app}

stop:
ifeq (${srv},)
	docker stack rm $(group)
else
	docker service rm $(group)_${srv}
endif

shutdown:
	docker service update --stop-grace-period 20s ${group}_${app}
	docker service scale ${group}_${app}=0


fab:
	make build app=${app} f=${f}
	#make push app=${app}
	make update yml=${app} app=${app}

fab-nginx:
	make build app=nginx f=nginx/Dockerfile
	#make push app=${app}
	make update yml=nginx app=nginx

initapp:
	make build app=${app} f=${f}
	#make push app=${app}
	docker stack deploy --with-registry-auth -c deployments/$(app).yml $(group)

login:
	docker login --username=$(username) $(registry_mirrors)

clean:
	yes | docker system prune

.PHONY: build flush api