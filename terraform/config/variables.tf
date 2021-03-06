###################################################################
# AWS configuration below
###################################################################

variable "aws_region" {
  default = "eu-west-1"
}

variable "aws_profile" {
  default = "default"
}

##############################################################################
# Resources configuration below
##############################################################################

### MANDATORY ###
variable "environment" {}

### MANDATORY ###
variable "colour" {}

### MANDATORY ###
variable "account_id" {}

### MANDATORY ###
variable "secrets_bucket_name" {}

### MANDATORY ###
variable "hosted_zone_name" {}

### MANDATORY ###
variable "shop_external_hostname" {}

### MANDATORY ###
variable "shop_internal_hostname" {}

### MANDATORY ###
variable "shop_sse_external_hostname_a" {}

### MANDATORY ###
variable "shop_sse_external_hostname_b" {}

### MANDATORY ###
variable "shop_sse_external_hostname_c" {}

### MANDATORY ###
variable "github_client_id" {}

### MANDATORY ###
variable "github_client_secret" {}

### MANDATORY ###
variable "github_user_email" {}

### MANDATORY ###
variable "keystore_password" {}

### MANDATORY ###
variable "truststore_password" {}

### MANDATORY ###
variable "cassandra_username" {}

### MANDATORY ###
variable "cassandra_password" {}

### MANDATORY ###
variable "mysql_username" {}

### MANDATORY ###
variable "mysql_password" {}
