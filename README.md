# amazonlinux2022

##### docker build
```
docker build -t anti1346/amazonlinux2022:sshd .
```

##### docker run
```
docker run -d -p 2222:22 --name amazonlinux anti1346/amazonlinux2022:sshd
```

##### docker-compose up
```
docker-compose up -d
```

##### docker-compose exec
```
docker-compose exec ssh-server bash
```

##### docker inspect
```
docker inspect --format='{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ssh-server
```

##### ssh connection
```
ssh ec2-user@localhost -p 2222
```
