server {
    server_name _;

    location / {
        proxy_pass http://localhost:$PORT;
    }
}