[Unit]
Description=Url Shortener
After=network.target

[Service]
User=nobody
ExecStart=/home/ubuntu/shortener -d $DOMAIN -p $PORT -t $DB_TABLE -r $REGION
[Install]
WantedBy=multi-user.target