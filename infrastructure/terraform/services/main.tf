##############################################################################
# Providers
##############################################################################

provider "aws" {
  region  = "${var.aws_region}"
  profile = "${var.aws_profile}"
  version = "~> 0.1"
}

provider "local" {
  version = "~> 0.1"
}

##############################################################################
# Resources
##############################################################################

resource "local_file" "auth_config" {
  content = <<EOF
{
  "host_port": 43000,

  "github_client_id": "${var.github_client_id}",
  "github_client_secret": "${var.github_client_secret}",

  "server_keystore_path": "/keystores/keystore-server.jks",
  "server_keystore_secret": "${var.keystore_password}",

  "client_keystore_path": "/keystores/keystore-client.jks",
  "client_keystore_secret": "${var.keystore_password}",

  "client_truststore_path": "/keystores/truststore-client.jks",
  "client_truststore_secret": "${var.truststore_password}",

  "client_verify_host": false,

  "jwt_keystore_path": "/keystores/keystore-auth.jceks",
  "jwt_keystore_type": "jceks",
  "jwt_keystore_secret": "${var.keystore_password}",

  "client_web_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",
  "client_auth_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",

  "server_auth_url": "https://shop-auth:43000",
  "server_accounts_url": "https://shop-accounts:43002",

  "github_url": "https://api.github.com",

  "oauth_login_url": "https://github.com/login",
  "oauth_token_path": "/oauth/access_token",
  "oauth_authorize_path": "/oauth/authorize",
  "oauth_authority": "user:email",

  "cookie_domain": "${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}",

  "admin_users": ["${var.github_user_email}"],

  "graphite_reporter_enabled": false,
  "graphite_host": "http://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}",
  "graphite_port": 2003
}
EOF

  filename = "../../secrets/environments/${var.environment}/${var.colour}/config/auth.json"
}

resource "local_file" "designs_config" {
  content = <<EOF
{
  "host_port": 43001,

  "server_keystore_path": "/keystores/keystore-server.jks",
  "server_keystore_secret": "${var.keystore_password}",

  "jwt_keystore_path": "/keystores/keystore-auth.jceks",
  "jwt_keystore_type": "jceks",
  "jwt_keystore_secret": "${var.keystore_password}",

  "client_web_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",

  "graphite_reporter_enabled": false,
  "graphite_host": "http://${var.environment}-${var.colour}-swarm-manager.${var.hosted_zone_name}",
  "graphite_port": 2003,

  "cassandra_cluster": "${var.environment}-${var.colour}",
  "cassandra_keyspace": "designs",
  "cassandra_username": "${var.verticle_username}",
  "cassandra_password": "${var.verticle_password}",
  "cassandra_contactPoint": "${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}",
  "cassandra_port": 9042,

  "max_execution_time_in_millis": 30000
}
EOF

  filename = "../../secrets/environments/${var.environment}/${var.colour}/config/designs.json"
}

resource "local_file" "accounts_config" {
  content = <<EOF
{
  "host_port": 43002,

  "server_keystore_path": "/keystores/keystore-server.jks",
  "server_keystore_secret": "${var.keystore_password}",

  "jwt_keystore_path": "/keystores/keystore-auth.jceks",
  "jwt_keystore_type": "jceks",
  "jwt_keystore_secret": "${var.keystore_password}",

  "client_web_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",

  "graphite_reporter_enabled": false,
  "graphite_host": "http://${var.environment}-${var.colour}-swarm-manager.${var.hosted_zone_name}",
  "graphite_port": 2003,

  "cassandra_cluster": "${var.environment}-${var.colour}",
  "cassandra_keyspace": "accounts",
  "cassandra_username": "${var.verticle_username}",
  "cassandra_password": "${var.verticle_password}",
  "cassandra_contactPoint": "${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}",
  "cassandra_port": 9042
}
EOF

  filename = "../../secrets/environments/${var.environment}/${var.colour}/config/accounts.json"
}

resource "local_file" "web_config" {
  content = <<EOF
{
  "host_port": 48080,

  "server_keystore_path": "/keystores/keystore-server.jks",
  "server_keystore_secret": "${var.keystore_password}",

  "client_keystore_path": "/keystores/keystore-client.jks",
  "client_keystore_secret": "${var.keystore_password}",

  "client_truststore_path": "/keystores/truststore-client.jks",
  "client_truststore_secret": "${var.truststore_password}",

  "client_verify_host": false,

  "jwt_keystore_path": "/keystores/keystore-auth.jceks",
  "jwt_keystore_type": "jceks",
  "jwt_keystore_secret": "${var.keystore_password}",

  "client_web_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",
  "client_auth_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",
  "client_designs_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",
  "client_accounts_url": "https://${var.environment}-${var.colour}-swarm-worker.${var.hosted_zone_name}:7443",

  "server_auth_url": "https://shop-auth:43000",
  "server_designs_url": "https://shop-designs:43001",
  "server_accounts_url": "https://shop-accounts:43002",

  "csrf_secret": "changeme",

  "graphite_reporter_enabled": false,
  "graphite_host": "http://${var.environment}-${var.colour}-swarm-manager.${var.hosted_zone_name}",
  "graphite_port": 2003
}
EOF

  filename = "../../secrets/environments/${var.environment}/${var.colour}/config/web.json"
}
