HAB_BOOTSTRAP_IMAGE_VERSION = "20230523"
HAB_AUTO_BUILD_GIT_REPO = "https://github.com/habitat-sh/hab-auto-build.git"
HAB_AUTO_BUILD_BRANCH = "v2"
PACKAGE = "*/*"

check-docker:
	@command -v docker >/dev/null 2>&1 || (echo "Docker is not installed. Please install Docker:  https://docs.docker.com/get-docker/" && exit 1)

check-rust:
	@command -v cargo >/dev/null 2>&1 || (echo "Cargo is not installed. Please install Rust: https://www.rust-lang.org/tools/install" && exit 1)

check-hab-auto-build:
	@command -v cargo >/dev/null 2>&1 || (echo "hab-auto-build is not found. Please install it by running 'make setup'" && exit 1)

build-hab-bootstrap-image: check-docker
	@echo "Building Docker Image for build tools: hab-bootstrap:$(HAB_BOOTSTRAP_IMAGE_VERSION)"
	@docker build -q -t hab-bootstrap:$(HAB_BOOTSTRAP_IMAGE_VERSION) docker/hab-bootstrap &> /dev/null
	@echo "Docker Image built hab-bootstrap:$(HAB_BOOTSTRAP_IMAGE_VERSION)"

install-hab-auto-build: check-rust
	@command -v hab-auto-build >/dev/null 2>&1 && \
	echo "Found hab-auto-build already installed at $$(command -v hab-auto-build)" \
	|| (echo "Installing hab-auto-build"; \
		cargo install --git $(HAB_AUTO_BUILD_GIT_REPO) --branch $(HAB_AUTO_BUILD_BRANCH); \
		echo "Installed hab-auto-build")
		
update-hab-auto-build: check-rust
	@echo "Updating hab-auto-build"
	@cargo install --git $(HAB_AUTO_BUILD_GIT_REPO) --branch $(HAB_AUTO_BUILD_BRANCH) --quiet;
	@echo "Updated hab-auto-build"

setup: build-hab-bootstrap-image install-hab-auto-build
	@echo "Installed all tools for building packages"

update: build-hab-bootstrap-image update-hab-auto-build
	@echo "Updated all tools for building packages"

build-dry-run: check-hab-auto-build
	hab-auto-build build -d $(PACKAGE)

build: check-hab-auto-build setup
	@echo "Building all packages matching $(PACKAGE)"
	hab-auto-build build $(PACKAGE)
	@echo "Built all packages matching $(PACKAGE)"

check: check-hab-auto-build
	@echo "Checking all packages matching $(PACKAGE)"
	hab-auto-build check $(PACKAGE)
	@echo "Checked all packages matching $(PACKAGE)"