.PHONY: build
build:
	docker build -t api:test .
	docker tag api:test registry.zachlov.in/api:latest
	docker push registry.zachlov.in/api:latest
