# Stage de Build
FROM golang:1.24 AS builder
WORKDIR /app

# Copia os arquivos de código-fonte
COPY go.mod go.sum ./
RUN go mod download

# Copia o restante do código-fonte
COPY . .

# Compila o binário estaticamente
# O binário será o executável principal
# O uso de -tags 'fts5' e -ldflags é para garantir a compilação estática e inclusão de recursos como o FTS5 (Full-Text Search)
RUN CGO_ENABLED=0 GOOS=linux go build -o stremthru -tags 'fts5' -ldflags '-linkmode external -extldflags "-static"' ./cmd/stremthru

# Stage Final
# Usamos uma imagem base leve para o runtime
FROM alpine:latest
WORKDIR /app

# Instala o git, necessário para o stremthru (verificado no Dockerfile original)
RUN apk update && apk add --no-cache git

# Copia o binário compilado do stage de build
COPY --from=builder /app/stremthru /app/stremthru

# Define o ponto de entrada (ENTRYPOINT) para o binário
# Este comando irá iniciar o serviço stremthru
ENTRYPOINT ["/app/stremthru"]

# Define a porta padrão (pode ser sobrescrita pela Discloud)
EXPOSE 8080
