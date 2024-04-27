# Use an existing image as a base
FROM node:14

# Set the working directory
WORKDIR /usr/src/server

# copy our package.json file from our local system to the docker image
COPY package.json .

# Install the dependencies
RUN npm install

# Copy the rest of the code
COPY . .

# Expose the port that the app listens on
EXPOSE 3000

# Define the command to run the app
CMD ["node", "app.js"]