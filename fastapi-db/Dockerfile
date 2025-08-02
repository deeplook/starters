# Use the official Python image.
FROM python:3.12-slim

# Set the working directory.
WORKDIR /app

# Create a non-root user.
RUN useradd --create-home appuser
USER appuser

# Add user's local bin to PATH
ENV PATH="/home/appuser/.local/bin:${PATH}"

# Copy the dependencies file.
COPY --chown=appuser:appuser pyproject.toml .

# Install dependencies.
RUN pip install --no-cache-dir "fastapi>=0.115.14" "uvicorn>=0.30.3" "python-dotenv>=0.21.0" "sqlmodel>=0.0.19"

# Copy the rest of the application code to the working directory
COPY . .

# Set default port
ENV MYAPP_PORT=8000

# Expose the port the app runs on
EXPOSE 8000

# Run the application
CMD ["python", "main.py"]
