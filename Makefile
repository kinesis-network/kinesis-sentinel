IMAGE_NAME := kinesisorg/kinesis-sentinel

.PHONY: build run stop clean

clean:
	-docker rm -f $(shell docker ps -aq -f ancestor=$(IMAGE_NAME)) 2>/dev/null || true
	-docker rmi $(IMAGE_NAME)

build: clean
	docker build -t $(IMAGE_NAME) .

logs:
	docker logs $(shell docker ps -aqf ancestor=$(IMAGE_NAME))

shell:
	docker exec -it $(shell docker ps -aqf ancestor=$(IMAGE_NAME)) /bin/bash

run:
	# Ensure the socket directory exists on the host before mounting
	sudo mkdir -p /var/run/tetragon
	# Run the container
	docker run -d --rm \
		--pid=host \
		--ipc=host \
		--cgroupns=host \
		--privileged \
		-v /sys/kernel/btf/vmlinux:/var/lib/tetragon/btf \
		-v /sys/kernel/debug:/sys/kernel/debug \
		-v /var/run/docker.sock:/var/run/docker.sock \
		-v /var/run/tetragon:/var/run/tetragon \
		$(IMAGE_NAME)
