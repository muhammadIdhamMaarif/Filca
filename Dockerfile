FROM node:slim

#ENV NODE_ENV development

WORKDIR /app

COPY . .

RUN npm install; npm run register

CMD [ "npm", "run", "start" ]
