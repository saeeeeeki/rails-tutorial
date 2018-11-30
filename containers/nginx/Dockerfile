FROM nginx

RUN apt-get update -qq && apt-get -y install apache2-utils
ENV RAILS_ROOT /var/www/workspace
WORKDIR $RAILS_ROOT

ADD default.conf /tmp/default.nginx
ADD nginx.conf /tmp/nginx.nginx

RUN envsubst '$RAILS_ROOT' < /tmp/default.nginx > /etc/nginx/conf.d/default.conf
RUN envsubst '$RAILS_ROOT' < /tmp/nginx.nginx > /etc/nginx/nginx.conf

EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
