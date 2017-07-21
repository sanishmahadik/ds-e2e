# ds-e2e
Docker images are available at

https://hub.docker.com/r/sanishmahadik/s3-success/

https://hub.docker.com/r/sanishmahadik/s3-failure/

## Build Docker Image 

```
docker build -t sanishmahadik/s3-failure:latest .
```

## Specify the AWS env. variables
```
$cat env.list
AWS_SECRET_ACCESS_KEY=<secret>
AWS_ACCESS_KEY_ID=<key>
```

## Run locally
```
docker run -t -i --env-file env.list  sanishmahadik/s3-failure:latest
```
