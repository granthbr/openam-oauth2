###OpenAM Docker container with predefined config (for OAuth 2.0)
Use it for deploying a running instance of OpenAM OAuth 

--NOTES for running strange openam:
docker run -i -t -p 8080:8080 --add-host "openam.example.com:127.0.0.1"

#####Pre-reqs
Create a host name on the server named iam.example.com and point it to localhost
Using docker-machine get the IP: docker machine ip <vm> 
	for exp: docker-machine ip box
Add the IP to the local host file: (on macOSX)
sudo vi /etc/hosts
Add:
<IP> iam.example.command
	

#####Building  the container
First, checkout the repo from the source hub in github. The openam directory is required to start with a prebuilt config
Next, build the container (or just jump to the run command below if all you need is an OAuth implementation)
```
docker build -t <your tag> .
	
For example: 
docker build -t granthbr/openam .
```

Or just run it and it will pull the trusted image (required: the openam folder with the configuration for OpenAM and the directory server)
```
docker run -it --rm=true  -v `pwd`/openam:/root/openam --name="openam-oauth" -p 8443:8443 granthbr/openam-cfg (don't use this unless it is built differently)
docker run -it --rm=true --name="openam-oauth" -p 8443:8443 -p 8080:8080 granthbr/openam-cfg
```