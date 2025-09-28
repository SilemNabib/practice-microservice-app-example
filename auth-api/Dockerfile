# ======================
# Stage 1: build
# ======================

FROM golang:1.18.2-alpine AS builder

# RUN apk add --no-cache git

WORKDIR /app

COPY go.mod go.sum ./
RUN go mod download

COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -ldflags="-s -w" -o auth-api .


# ======================
# Stage 2: runtime
# ======================

FROM alpine:latest

# RUN apk --no-cache add ca-certificates

WORKDIR /root/

COPY --from=builder /app/auth-api .

EXPOSE 8000

ENV AUTH_API_PORT=8000
ENV USERS_API_ADDRESS=http://127.0.0.1:8083

ENTRYPOINT ["./auth-api"]