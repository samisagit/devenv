build:
	docker build -t devenv:latest .

clean:
	docker build --no-cache -t devenv:latest .

dev:
	docker run -it -v $(shell pwd):/home/dev/code devenv:latest .
