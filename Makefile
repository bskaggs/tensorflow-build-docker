.PHONY: build


build: tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl
	docker build -t tensorflow .

tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl: Dockerfile.build
	docker build -f Dockerfile.build -t tensorflow-build .
	ID=$$(docker create tensorflow-build /bin/true) && docker cp $$ID:/tmp/tensorflow_pkg/tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl tensorflow-0.9.0rc0-cp27-none-linux_x86_64.whl && docker rm $$ID

