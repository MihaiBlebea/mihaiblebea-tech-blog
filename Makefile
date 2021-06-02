setup: build run

build:
	docker build \
		--rm \
		-f ./Dockerfile \
		-t serbanblebea/mihaiblebea-tech:0.1 \
		.

run:
	docker run \
		--env-file ./.env \
		-d \
		--name mihaiblebea-tech \
		-p 8081:80 \
		serbanblebea/mihaiblebea-tech:0.1

run-vol:
	docker run \
		-d \
		--name mihaiblebea-tech \
		-v $(pwd)/vol:/var/log/nginx \
		serbanblebea/mihaiblebea-tech:0.1

remove:
	docker stop mihaiblebea-tech && \
	docker rm -f mihaiblebea-tech