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
<<<<<<< HEAD

# Hello Man
=======
>>>>>>> a190ae4... 	new file:   0336090eb38a
