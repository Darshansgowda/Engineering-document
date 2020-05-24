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