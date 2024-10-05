
docker build --platform linux/amd64 -t nginx-health-check .
docker run --name nginx-health -p 8000:8000 --rm -d nginx-health-check
curl http://localhost:8000/health/

Dockerhub:
docker pull armanbektassov/nginx-health-check:1.0
docker run --name nginx-health -p 8000:8000 --rm -d armanbektassov/nginx-health-check:1.0
curl http://localhost:8000/health/