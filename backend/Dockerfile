FROM node:20-alpine

WORKDIR /app

# Instala dependencias primero para aprovechar la caché de capas.
COPY package.json ./
RUN npm install --omit=dev

# Copia el resto del código.
COPY . .

EXPOSE 3000

CMD ["node", "src/index.js"]
