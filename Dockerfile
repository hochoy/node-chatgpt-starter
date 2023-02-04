# small alpine.
FROM node:lts-alpine

# setting the workdir determines where the following commands are run
WORKDIR /home/node/app

# copy npm files and install
COPY ./package.json       /home/node/app/package.json
COPY ./package-lock.json  /home/node/app/package-lock.json
RUN npm install

# copy the source code and settings file
# WARNING: the settings file is gitignored, as it (currently) contains the secret API key. Consider refactoring this out of the image
COPY ./src /home/node/app/src
COPY ./settings.js        /home/node/app/settings.js

EXPOSE 3000
ENTRYPOINT ["npm"]
CMD ["start"]