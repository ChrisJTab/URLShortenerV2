# https://docs.docker.com/engine/reference/builder/

# Use an official Python runtime as a parent image
# See https://hub.docker.com/ and search for python:2.7-slim
FROM registry-server.taild476f.ts.net/python:3.8

# Set the working directory to /app
# The WORKDIR instruction sets the working directory (inside the container) 
# for any RUN, CMD, ENTRYPOINT, COPY and ADD instructions that 
# follow it in the Dockerfile. 
WORKDIR /app

# Copy the application directory (app) contents into the container at /app
ADD app /app

# Install any needed packages specified in requirements.txt
# RUN during image build
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Build Cassandra-Drivers with multi-thread
RUN CASS_DRIVER_BUILD_CONCURRENCY=8 pip install cassandra-driver

# Run python URLShortner.py when the container launches
CMD ["python", "writer.py"]
