# I use the official Python 3.9 image as the base for my application container.
FROM python:3.9

# I set the working directory inside the container to /app.
WORKDIR /app

# I copy all my application files into the container image.
COPY . .

# I make sure my .env file is available inside the /app directory.
COPY .env /app/.env

# I install all Python dependencies listed in requirements.txt.
RUN pip install --no-cache-dir -r requirements.txt

# I run my Flask application using run.py as the entrypoint.
CMD ["python", "run.py"]
