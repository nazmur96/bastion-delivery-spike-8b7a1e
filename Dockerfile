FROM nginxinc/nginx-unprivileged:1.27-alpine
COPY app/default.conf /etc/nginx/conf.d/default.conf
COPY app/index.html /usr/share/nginx/html/index.html
