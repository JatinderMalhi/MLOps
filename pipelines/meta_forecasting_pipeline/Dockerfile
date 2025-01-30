FROM python:3.10.16

# Set the working directory
WORKDIR /app

# Copy the requirements file (relative to the context)
COPY requirements.txt .

# Upgrade pip and install required packages
RUN pip install --upgrade pip
RUN pip install -r requirements.txt

# Copy the rest of the application code
COPY src/ .

# Set the PYTHONPATH environment variable
ENV PYTHONPATH=/app

# Command to run your application (optional, modify as needed)
# CMD ["python", "pipeline.py", "--compile-only"]