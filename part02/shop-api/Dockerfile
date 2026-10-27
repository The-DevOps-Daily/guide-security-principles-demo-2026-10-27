FROM python:3.14.7-alpine3.24@sha256:9e9fde4d32eedce0b661d9ab91e826b62dddf28e928c230ec55f1866cac66b01
WORKDIR /app
COPY server.py .
USER 10001:10001
EXPOSE 8080
CMD ["python3", "/app/server.py"]
