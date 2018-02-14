#!/bin/sh

rabbitmqctl add_user testuser testuser
rabbitmqctl set_user_tags testuser administrator
rabbitmqctl set_permissions -p / testuser ".*" ".*" ".*"
`

# Get the cli and make it available to use.
wget http://127.0.0.1:15672/cli/rabbitmqadmin

chmod +x rabbitmqadmin

mv rabbitmqadmin ./bin/
