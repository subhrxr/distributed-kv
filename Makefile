# Makefile - wrapper around CMake
# - configure runs before build
# - build shows hint on failure
# - run only executes binary (no build)

BUILD_DIR := build
BIN_NAME := kv_node
CMAKE := cmake

.PHONY: all configure build run test clean rebuild debug

# default: configure + build
all: build

# configure (explicit and reliable)
# uses cmake -S . -B build which always writes CMakeCache.txt into build/
configure:
	@echo "[CMake] Configuring..."
	@$(CMAKE) -S . -B $(BUILD_DIR) -DBUILD_TESTS=ON || { echo "CMake configure failed. Inspect $(BUILD_DIR)/CMakeFiles/CMakeOutput.log or rerun: cd $(BUILD_DIR) && cmake .."; exit 1; }

# build depends on configure so make build will first configure if needed
build: configure
	@echo "[CMake] Building..."
	@$(CMAKE) --build $(BUILD_DIR) -- -j$(shell nproc) || { echo "Build failed — run 'cmake --build $(BUILD_DIR) -- -j1' to see output"; exit 1; }

# run: run binary directly (no build)
run:
	@if [ -x "$(BUILD_DIR)/$(BIN_NAME)" ]; then \
	  "$(BUILD_DIR)/$(BIN_NAME)"; \
	elif [ -x "$(BUILD_DIR)/src/$(BIN_NAME)" ]; then \
	  "$(BUILD_DIR)/src/$(BIN_NAME)"; \
	else \
	  echo "ERROR: binary not found. Run 'make' to build."; exit 1; \
	fi

# test: build then run tests
test: build
	@$(CMAKE) --build $(BUILD_DIR) --target test || { echo "Tests failed / build failed. Run 'cmake --build $(BUILD_DIR) -- -j1' for details"; exit 1; }

# Hard rebuild (clean + configure + build)
rebuild: clean all

# Debug mode: configure & build with verbose output and sanitizers
debug:
	@echo "[CMake] Debug configure + build (sanitizers enabled)"
	@rm -rf $(BUILD_DIR)
	@$(CMAKE) -S . -B $(BUILD_DIR) -DCMAKE_BUILD_TYPE=Debug -DENABLE_SANITIZERS=ON || { echo "CMake configure failed"; exit 1; }
	@$(CMAKE) --build $(BUILD_DIR) -- -j$(shell nproc) || { echo "Build failed"; exit 1; }

clean:
	@echo "[Clean] Removing $(BUILD_DIR)"
	@rm -rf $(BUILD_DIR)
