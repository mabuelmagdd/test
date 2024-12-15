# Use official Nginx image as a base
FROM nginx:alpine

# Copy a custom index.html file into the container
COPY index.html /usr/share/nginx/html/

# Expose port 80
EXPOSE 80
