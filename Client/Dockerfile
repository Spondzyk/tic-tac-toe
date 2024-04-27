# define the base image on top of which our application will run
FROM node:18-alpine

# working directory of the docker container
WORKDIR /app

# copy our package.json file from our local system to the docker image
COPY package.json .

# run npm install inside the docker image to install all our dependencies
RUN npm install

# copy the rest of the files into the docker image
COPY . .

# convention and a good practice that declares on which port the application “should” run and not must run
EXPOSE 8080

CMD [ "npm", "run", "dev" ]