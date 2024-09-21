# Use the official Python image from the Docker Hub
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /scripts

# Copy the Python script into the container
COPY scripts .

# Command to run the Python script
CMD ["python", "hello.py"]