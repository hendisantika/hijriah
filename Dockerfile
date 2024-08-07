# Use an official Node.js, and it should be version 16 and above
FROM node:20-alpine
LABEL authors="hendisantika"
ENV NUXT_HOST=0.0.0.0
ENV NUXT_PORT=3001
# Set the working directory in the container
WORKDIR /app
RUN apk --no-cache add openssh g++ make python3 git
# Copy package.json and pnpm-lock.yaml
COPY package.json /app
COPY pnpm-lock.yaml /app
# Install app dependencies using PNPM
RUN npm install -g pnpm
# Install dependencies
RUN pnpm i
# Copy the application code
COPY ./ /app
# Build the TypeScript code
RUN pnpm run build
RUN pnpm generate
# Expose the app
ENV PORT=3001
EXPOSE 3001
# Start the application
CMD ["pnpm", "start"]
#CMD ["node", "/app/.output/server/index.mjs"]
# run the build project with node
#ENTRYPOINT ["node", ".output/server/index.mjs"]
