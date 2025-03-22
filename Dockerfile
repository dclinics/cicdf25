# Use Python 3.10 slim as base image
FROM python:3.10-slim

# Set working directory inside the container
WORKDIR /app

# Copy your application code
COPY app.py .

# Install Flask
RUN pip install flask

# Expose the port your app runs on
EXPOSE 5000

# Define the command to run your app
CMD ["python", "app.py"]
