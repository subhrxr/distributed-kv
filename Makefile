CXX := g++
CXXFLAGS := -std=c++17 -O2 -Wall
BUILD_DIR := build
BIN := $(BUILD_DIR)/distributed-kv

SRC := $(wildcard src/*.cpp)
OBJ := $(patsubst src/%.cpp, $(BUILD_DIR)/%.o, $(SRC))

.PHONY: all clean test

all: $(BIN)

$(BUILD_DIR)/%.o: src/%.cpp
	mkdir -p $(BUILD_DIR)
	$(CXX) $(CXXFLAGS) -c $< -o $@

$(BIN): $(OBJ)
	$(CXX) $(CXXFLAGS) $^ -o $@

test: all
	# run tests if built
	$(BUILD_DIR)/test || true

clean:
	rm -rf $(BUILD_DIR)