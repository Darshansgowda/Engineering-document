# build environment
FROM node:14.0.0 as react-build
WORKDIR /usr/src/app
RUN yarn
COPY ./frontend /usr/src/app
COPY ./frontend/package.json /usr/src/app
RUN npm install react-scripts -g --silent
RUN yarn add react
RUN yarn build

# server environment
FROM nginx:alpine
COPY ./frontend/nginx.conf /etc/nginx/conf.d/configfile.template
ENV PORT 8080
ENV HOST 0.0.0.0
RUN sh -c "envsubst '\$PORT'  < /etc/nginx/conf.d/configfile.template > /etc/nginx/conf.d/default.conf"
COPY --from=react-build /usr/src/app/build /usr/share/nginx/html
EXPOSE 8080
CMD ["nginx", "-g", "daemon off;"]


#######cloudbuild###########

steps:
- name: 'gcr.io/cloud-builders/docker'
  args: ['build', '-f', 'frontend/Dockerfile', '-t', 'gcr.io/qi-gcp-partner2/react-docker-app:$SHORT_SHA', '.']
- name: 'gcr.io/cloud-builders/docker'
  args: ['push', 'gcr.io/qi-gcp-partner2/react-docker-app:$SHORT_SHA']
- name: 'gcr.io/cloud-builders/gcloud'
  args: ['beta', 'run', 'deploy', 'qi-gcp-partner2', '--region=us-central1', '--platform=managed', '--image=gcr.io/qi-gcp-partner2/react-docker-app:$SHORT_SHA', '--memory=2G']


####nginixconfig#########
  server {
     listen       $PORT;
     server_name  localhost;

     location / {
         root   /usr/share/nginx/html;
         index  index.html index.htm;
         try_files $uri /index.html;
     }

     gzip on;
     gzip_vary on;
     gzip_min_length 10240;
     gzip_proxied expired no-cache no-store private auth;
     gzip_types text/plain text/css text/xml text/javascript application/x-javascript application/xml;
     gzip_disable "MSIE [1-6]\.";

}


FROM ubuntu:18.04
COPY . /app
RUN make /app
CMD python /app/app.py

Each instruction creates one layer:

FROM creates a layer from the ubuntu:18.04 Docker image.
COPY adds files from your Docker client’s current directory.
RUN builds your application with make.
CMD specifies what command to run within the container.


Docker commands

 
 1985  docker build -t darshan/node-web-app .
 1986  sudo docker build -t darshan/node-web-app .
 1987  sudo docker ps
 1988  docker images
 1989  sudo docker images
       sudo docker run -p 49160:8080 -d darshan/node-web-app
 1990  docker run -p 49160:8080 -d darshan/node-web-app
 1992  curl -i localhost:49160
 1993  sudo docker ps
 1995  docker run -p 49160:8080 -d darshan/node-web-app
 1996  sudo docker run -p 49160:8080 -d darshan/node-web-app
 1997  sudo docker ps
 1998  docker exec -it 0930bd64dd62/bin/bash
 1999  docker exec -it 0930bd64dd62 /bin/bash
 2000  sudo docker exec -it 0930bd64dd62 /bin/bash
 2001  docker run -p 49160:8080 -d <your username>/node-web-app
 2002  docker run -p 49160:8080 -d darshan/node-web-app
 2003  sudo docker run -p 49160:8080 -d darshan/node-web-app
 2004  npx kill-port 49160
 2005  sudo docker run -p 49160:8080 -d darshan/node-web-app
 2006  docker-machine ip default
 2007  docker container ls
 2008  sudo docker container ls
 2009  docker rm -f 0930bd64dd62
 2010  sudo docker rm -f 0930bd64dd62
 2011  sudo docker container ls
 2012  sudo docker run -p 49160:8080 -d darshan/node-web-app
 2013  docker-machine ip default
 2014  sudo docker container ls -a
       sudo docker rm -f 0930bd64dd62
 2024  sudo docker stop 4c70e6bd96e6
 2026  sudo docker start 4c70e6bd96e6
       sudo docker image rm -f image darshan/node-web-app