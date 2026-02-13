FROM node:18-alpine
WORKDIR /opt
RUN apk update && apk upgrade --no-cache
COPY . /opt
RUN npm install
ENTRYPOINT ["npm", "run", "start"]
