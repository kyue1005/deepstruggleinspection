server {
    server_name $DOMAIN;

    location / {
        proxy_pass http://localhost:$PORT;
    }
}