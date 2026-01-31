# node:19-alpine amd64
FROM node@sha256:d0ba7111bc031323ce2706f8e424afc868db289ba40ff55b05561cf59c123be1 AS node

WORKDIR /app

ENV NODE_ENV="production"

COPY package-lock.json package.json ./

RUN apk update && apk add python3 build-base && npm ci --ignore-scripts

COPY . .

CMD [ "npm", "start" ]