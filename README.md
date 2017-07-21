# ds-e2e
Docker images are available at

https://hub.docker.com/r/sanishmahadik/object-store-success/

https://hub.docker.com/r/sanishmahadik/object-store-failure/

## Build Docker Image 

```
docker build -t sanishmahadik/object-store-failure:latest .
```

## Specify the AWS env. variables
```
$cat env.list
AWS_SECRET_ACCESS_KEY=<secret>
AWS_ACCESS_KEY_ID=<key>
```

## Run locally
```
docker run -t -i --env-file env.list  sanishmahadik/object-store-failure:latest
```
