# Choose our base image
FROM node:20

# Set build directory
WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y curl unzip bash
RUN curl -fsSL https://get.docker.com -o get-docker.sh && sh get-docker.sh

# -------------------------
# Install Terraform
# -------------------------
ENV TERRAFORM_VERSION=1.7.4
RUN curl -fsSL https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip -o terraform.zip \
    && unzip terraform.zip \
    && mv terraform /usr/local/bin/terraform \
    && chmod +x /usr/local/bin/terraform \
    && rm terraform.zip

# -------------------------
# Set development state
# -------------------------
ENV NODE_ENV=development

# Copy package files
COPY package*.json ./

# Install all dependencies (including devDependencies for 'npm run dev')
RUN npm install

# Copy source code
COPY . .

# Expose Next.js port
EXPOSE 3000

# Start deployment using npm run dev (for local development inside docker)
CMD ["npm", "run", "dev"]
