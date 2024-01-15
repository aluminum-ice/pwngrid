VERSION=$(shell git describe --abbrev=0 --tags)

all: clean
	@mkdir build
	@go build -o build/pwngrid cmd/pwngrid/*.go
	@ls -la build/pwngrid

install:
	@cp build/pwngrid /usr/local/bin/
	@mkdir -p /etc/systemd/system/
	@cp pwngrid.service /etc/systemd/system/
	@mkdir -p /etc/pwngrid/
	@cp env.example /etc/pwngrid/pwngrid.conf
	@chmod 644 /etc/systemd/system/pwngrid.service
	@systemctl daemon-reload
	@systemctl enable pwngrid.service

clean:
	@rm -rf build

restart:
	@service pwngrid restart

release_files: clean
	@mkdir build
	@echo building for linux/arm64 ...
	@GOARM=6 GOARCH=arm64 GOOS=linux go build -o build/pwngrid cmd/pwngrid/*.go
	@zip -j "build/pwngrid_linux_arm64_$(VERSION).zip" build/pwngrid > /dev/null
	@rm -rf build/pwngrid
	@echo building for linux/amd64 ...
	@GOARM=6 GOARCH=amd64 GOOS=linux go build -o build/pwngrid cmd/pwngrid/*.go
	@zip -j "build/pwngrid_linux_amd64_$(VERSION).zip" build/pwngrid > /dev/null
	@rm -rf build/pwngrid
	@echo building for linux/armv6l ...
	@GOARM=6 GOARCH=arm GOOS=linux go build -o build/pwngrid cmd/pwngrid/*.go
	@zip -j "build/pwngrid_linux_armv6l_$(VERSION).zip" build/pwngrid > /dev/null
	@rm -rf build/pwngrid
	@openssl dgst -sha256 "build/pwngrid_linux_amd64_$(VERSION).zip" > "build/pwngrid-hashes.sha256"
	@openssl dgst -sha256 "build/pwngrid_linux_armv6l_$(VERSION).zip" >> "build/pwngrid-hashes.sha256"
	@ls -la build
