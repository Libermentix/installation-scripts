#!/bin/bash
echo "Installing nginx..."
APPNAME=$1
apt-get install --force-yes nginx > /dev/null

echo "creating config file /etc/nginx/sites-available/${APPNAME}"

cat > /etc/nginx/sites-available/${APPNAME} << EOF
server {
   listen 80;
   server_name uploads.${APPNAME}.com;

   access_log /home/sites/virtualenvs/${APPNAME}/logs/nginx-media-cdn-access.log;
   error_log /home/sites/virtualenvs/${APPNAME}/logs/nginx-media-cdn-error.log;

   location / {
      root /home/sites/apps/${APPNAME}/assets/uploads/;
   }
}

server {
   listen 80;
   server_name static.${APPNAME}.com;

   access_log /home/sites/virtualenvs/${APPNAME}/logs/nginx-static-cdn-access.log;
   error_log /home/sites/virtualenvs/${APPNAME}/logs/nginx-static-cdn-error.log;

   location / {
      root /home/sites/apps/${APPNAME}/assets/static/;
      
      ## hack to overcome cross site protection in ff and ie.
      if (\$request_filename ~* "^.*?\.(eot)|(ttf)|(woff)$"){
          add_header Access-Control-Allow-Origin *;
      }
   }
   
}



upstream ${APPNAME}_server {
  server unix:/home/sites/virtualenvs/${APPNAME}/run/gunicorn.sock fail_timeout=0;
}

server {
    listen 80;
    server_name www.${APPNAME}.com;
    return 301 \$scheme://${APPNAME}.com\$request_uri;
}

server {

    listen  80;
    server_name ${APPNAME}.com;

    client_max_body_size 4G;

    access_log /home/sites/virtualenvs/${APPNAME}/logs/nginx-access.log;
    error_log  /home/sites/virtualenvs/${APPNAME}/logs/nginx-error.log;

    location / {
        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;

        # proxy_set_header Host \$http_host;
        proxy_set_header Host \$http_host;

        proxy_redirect off;

        # set "proxy_buffering off" *only* for Rainbows! when doing
        # Comet/long-poll stuff.  It's also safe to set if you're
        # using only serving fast clients with Unicorn + nginx.
        # Otherwise you _want_ nginx to buffer responses to slow
        # clients, really.
        # proxy_buffering off;

        # Try to serve static files from nginx, no point in making an
        # *application* server like Unicorn/Rainbows! serve static files.
        if (!-f \$request_filename) {
            proxy_pass http://${APPNAME}_server;
            break;
        }
    }

    # Error pages
    error_page 500 502 503 504 /500.html;
    location = /500.html {
        root /home/sites/apps/${APPNAME}/templates/;
    }
}
EOF
echo "moving nginx config into place"
ln -s /etc/nginx/sites-available/${APPNAME} /etc/nginx/sites-enabled/${APPNAME}
echo "Testing configuration and attempting restart..."
nginx -t && service nginx restart

