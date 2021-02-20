FROM node

RUN mkdir /skillbox
WORKDIR /skillbox
COPY package.json /skillbox
RUN yarn install

COPY . /skillbox

RUN yarn test
RUN yarn build

CMD yarn start

EXPOSE 3000
