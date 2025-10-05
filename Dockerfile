# Use an official Node.js runtime
FROM node:18-slim

# Install openssl, as recommended by Prisma
RUN apt-get update && apt-get install -y openssl

# Set the working directory
WORKDIR /usr/src/app

# --- THIS IS THE KEY CHANGE ---
# 1. Copy package files first
COPY package*.json ./

# 2. Install dependencies to leverage Docker cache
RUN npm install

# 3. NOW copy the rest of your application code, including the prisma schema
COPY . .

# 4. NOW, run prisma generate, since the schema is available
RUN npx prisma generate
# --- END CHANGE ---


# Your app binds to port 3000
EXPOSE 3000

# The command to run your app
CMD [ "node", "index.js" ]