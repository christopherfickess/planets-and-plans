
base_parameter="/mattermost-dev-chris-self-hosted"
password_param="${base_parameter}/db_password"
username_param="${base_parameter}/db_username"


MATTERMOST_CONFIG_FILE="/opt/mattermost/config/config.json"
MATTERMOST_DB_ENDPOINT="mattermostdb-ec2-chris-fickess-mattermost-191123.cgea1ldhmknm.us-east-1.rds.amazonaws.com"

MATTERMOST_DB_USERNAME=$(aws ssm get-parameter --name \
        "${username_param}" --with-decryption \
        --query "Parameter.Value" --output text)

MATTERMOST_DB_PASSWORD=$(aws ssm get-parameter --name \
        "${password_param}" --with-decryption \
        --query "Parameter.Value" --output text)
MATTERMOST_DATASOURCE="postgres://$MATTERMOST_DB_USERNAME:$MATTERMOST_DB_PASSWORD@$MATTERMOST_DB_ENDPOINT:5432/mattermost?sslmode=disable&connect_timeout=10"

TMP_FILE=$(mktemp)

jq --arg dsn "$MATTERMOST_DATASOURCE" \
        '.SqlSettings.DataSource = $dsn' \
        "$MATTERMOST_CONFIG_FILE" > "$TMP_FILE"

mv "$TMP_FILE" "$MATTERMOST_CONFIG_FILE"
chown mattermost:mattermost "$MATTERMOST_CONFIG_FILE"



systemctl daemon-reload
systemctl enable mattermost
systemctl start mattermost
systemctl status mattermost






####################
unique_name_suffix="dev.cloud.mattermost.com"
mattermost_email="Christopher.Fickess@mattermost.com"
mattermost_domain="chris-fickess.chat.${unique_name_suffix}.com"

certbot --nginx -d ${mattermost_domain} \
  --non-interactive \
  --agree-tos \
  --email ${mattermost_email} \
  --redirect

####### old ~~~~~~~~~~~~~~~
server {
    listen 80;
    server_name chris-fickess.chat.dev.cloud.mattermost.com;

    # Redirect all HTTP requests to HTTPS
    return 301 https://$host$request_uri;
}

server {
    listen 443 ssl;
    server_name chris-fickess.chat.dev.cloud.mattermost.com;

    ssl_certificate /etc/letsencrypt/live/chris-fickess.chat.dev.cloud.mattermost.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/chris-fickess.chat.dev.cloud.mattermost.com/privkey.pem;

    # Increase upload size limit
    client_max_body_size 100M;

    location / {
        proxy_pass http://localhost:8065;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header Host $host;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_buffering off;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}