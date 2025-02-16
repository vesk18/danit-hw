FROM python:3.10-slim
WORKDIR /app
COPY . /app
RUN pip install --no-cache-dir -r requirements.txt
RUN pip install gunicorn
EXPOSE 8000
ENV FLASK_APP=app.py
ENV FLASK_ENV=production
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "app:app"]

