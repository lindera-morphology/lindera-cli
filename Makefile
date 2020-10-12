BIN_DIR ?= ./bin

LINDERA_CLI_VERSION ?= $(shell cargo metadata --no-deps --format-version=1 | jq -r '.packages[] | select(.name=="lindera-cli") | .version')

.DEFAULT_GOAL := build

clean:
	rm -rf $(BIN_DIR)
	cargo clean

format:
	cargo fmt

build:
	mkdir -p $(BIN_DIR)
	cargo build --release
	cp -p ./target/release/lindera $(BIN_DIR)

test:
	cargo test

tag:
	git tag v$(LINDERA_VERSION)
	git push origin v$(LINDERA_VERSION)

publish:
ifeq ($(shell curl -s -XGET https://crates.io/api/v1/crates/lindera-cli | jq -r '.versions[].num' | grep $(LINDERA_CLI_VERSION)),)
	(cd lindera-cli && cargo package && cargo publish)
endif

docker-build:
ifeq ($(shell curl -s 'https://registry.hub.docker.com/v2/repositories/linderamorphology/lindera-cli/tags' | jq -r '."results"[]["name"]' | grep $(LINDERA_CLI_VERSION)),)
	docker build --tag=linderamorphology/lindera-cli:latest --build-arg="LINDERA_CLI_VERSION=$(LINDERA_CLI_VERSION)" .
	docker tag linderamorphology/lindera-cli:latest linderamorphology/lindera-cli:$(LINDERA_CLI_VERSION)
endif

docker-push:
ifeq ($(shell curl -s 'https://registry.hub.docker.com/v2/repositories/linderamorphology/lindera-cli/tags' | jq -r '."results"[]["name"]' | grep $(LINDERA_CLI_VERSION)),)
	docker push linderamorphology/lindera-cli:latest
	docker push linderamorphology/lindera-cli:$(LINDERA_CLI_VERSION)
endif

docker-clean:
ifneq ($(shell docker ps -f 'status=exited' -q),)
	docker rm $(shell docker ps -f 'status=exited' -q)
endif
ifneq ($(shell docker images -f 'dangling=true' -q),)
	docker rmi -f $(shell docker images -f 'dangling=true' -q)
endif
ifneq ($(docker volume ls -f 'dangling=true' -q),)
	docker volume rm $(docker volume ls -f 'dangling=true' -q)
endif
