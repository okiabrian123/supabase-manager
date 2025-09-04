FROM golang:1.21-alpine AS builder

WORKDIR /app

# Install dependencies
RUN apk add --no-cache git

# Copy go mod files
COPY go.mod go.sum ./
RUN go mod download

# Copy source code
COPY . .

# Build the application
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o main .

# Final stage
FROM alpine:latest

# Install docker and docker-compose for container management
RUN apk add --no-cache ca-certificates docker docker-compose postgresql-client

# Create app directory
WORKDIR /root/

# Copy binary from builder
COPY --from=builder /app/main .
COPY --from=builder /app/templates ./templates

# Expose port
EXPOSE 8090

# Run the application
CMD ["./main"]