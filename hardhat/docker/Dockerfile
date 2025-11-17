FROM node:22-bullseye

RUN apt update && apt -y upgrade

WORKDIR hardhat

RUN npm install -g npm
RUN npm install --save-dev hardhat
RUN apt install vim -y
RUN npm install dotenv

