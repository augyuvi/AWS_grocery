# I use the official Python 3.9 image as the base for my application container.
FROM python:3.9

# I set the working directory inside the container to /app.
WORKDIR /app

# I copy all my application files into the container image.
COPY . .

# NOTE:
# I do NOT copy my real .env into the image.
# That is unsafe. Instead I pass environment variables in ECS or EC2.
# So this line is intentionally removed:
# COPY .env /app/.env

# I install all Python dependencies listed in requirements.txt.
RUN pip install --no-cache-dir -r requirements.txt

# I run my Flask application using run.py as the entrypoint.
CMD ["python", "run.py"]

