FROM python:3.10

WORKDIR /app

COPY /app /app

EXPOSE 8080

RUN pip3 install -r requirements.txt

CMD ["python", "app.py"]