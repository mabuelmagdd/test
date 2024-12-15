# Use a specific version of Python for better consistency
FROM python:3.8.10-slim

# Set environment variables to optimize the build process
ENV PYTHONUNBUFFERED 1
ENV PYTHONDONTWRITEBYTECODE 1

# Set the working directory in the container
WORKDIR /app

# Copy only necessary files, reducing the image size
COPY requirements.txt /app/

# Install the dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest of the application code
COPY . /app/

# Expose the port the app will run on
EXPOSE 5000

# Use a production-ready WSGI server (Gunicorn for Flask apps)
CMD ["gunicorn", "-b", "0.0.0.0:5000", "app:app"]
