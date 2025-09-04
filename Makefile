# Makefile for Supabase Manager

# Variables
BINARY_NAME=supabase-manager
DOCKER_IMAGE=supabase-manager

# Default target
.PHONY: all
all: build

# Build the application
.PHONY: build
build:
	go build -o ${BINARY_NAME} .

# Run the application
.PHONY: run
run:
	go run main.go

# Run tests
.PHONY: test
test:
	go test -v ./...

# Clean build artifacts
.PHONY: clean
clean:
	rm -f ${BINARY_NAME}

# Install dependencies
.PHONY: deps
deps:
	go mod tidy

# Build Docker image
.PHONY: docker-build
docker-build:
	docker build -t ${DOCKER_IMAGE} .

# Run Docker container
.PHONY: docker-run
docker-run:
	docker run -p 8090:8090 ${DOCKER_IMAGE}

# Run with Docker Compose
.PHONY: docker-compose-up
docker-compose-up:
	docker-compose up -d

# Stop Docker Compose
.PHONY: docker-compose-down
docker-compose-down:
	docker-compose down

# Quick start (install deps, build, and run)
.PHONY: quick-start
quick-start: deps build run

# Help
.PHONY: help
help:
	@echo "Available targets:"
	@echo "  all              - Build the application (default)"
	@echo "  build            - Build the application"
	@echo "  run              - Run the application"
	@echo "  test             - Run tests"
	@echo "  clean            - Clean build artifacts"
	@echo "  deps             - Install dependencies"
	@echo "  docker-build     - Build Docker image"
	@echo "  docker-run       - Run Docker container"
	@echo "  docker-compose-up - Run with Docker Compose"
	@echo "  docker-compose-down - Stop Docker Compose"
	@echo "  quick-start      - Install deps, build, and run"
	@echo "  help             - Show this help"