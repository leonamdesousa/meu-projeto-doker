# --- Estágio 1: Build / Dependências ---
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --only=production

# --- Estágio 2: Imagem Final de Execução ---
FROM node:20-alpine
WORKDIR /app

# 1. Como root, cria a pasta de persistência do SQLite e ajusta as permissões para o usuário 'node'
RUN mkdir -p /etc/todos && chown -R node:node /etc/todos /app

# 2. Copia as dependências e o código com as permissões corretas
COPY --chown=node:node --from=builder /app/node_modules ./node_modules
COPY --chown=node:node src ./src
COPY --chown=node:node package*.json ./

# 3. Muda para o usuário não-root 'node' (exigido pelos requisitos de segurança)
USER node

EXPOSE 3000

CMD ["node", "src/index.js"]