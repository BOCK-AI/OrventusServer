# Use an official Node.js runtime as a parent image
FROM node:18-slim

# Set the working directory in the container
WORKDIR /usr/src/app

# Copy package.json and package-lock.json
COPY package*.json ./

# Install app dependencies
RUN npm install

# Copy the rest of the application code into the container
COPY . .

# Your app binds to port 3000, so you need to expose this port
EXPOSE 3000

# The command to run your app
CMD [ "node", "index.js" ]