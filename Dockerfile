# Stage 1: Build
FROM golang:1.24-alpine AS builder
WORKDIR /app
# Install build dependencies
RUN apk add --no-cache git
# Copy go mod and sum files
COPY go.mod go.sum ./
RUN go mod download
# Copy source code
COPY . .
# Build the binary statically with verbose output for debugging
RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -v -o ssosync .

# Stage 2: Final
FROM gcr.io/distroless/static:nonroot
WORKDIR /

# Copy the binary to /usr/bin so it is definitely in the $PATH
COPY --from=builder /app/ssosync /usr/bin/ssosync

# Use the nonroot user (UID 65532) provided by the base image
USER 65532:65532

# Use absolute path for the entrypoint
ENTRYPOINT ["/usr/bin/ssosync"]
