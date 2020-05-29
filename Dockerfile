FROM node:latest

COPY . .

RUN apt-get update && apt-get install -y jq

RUN npm ci

ENTRYPOINT ["/entrypoint.sh"]
