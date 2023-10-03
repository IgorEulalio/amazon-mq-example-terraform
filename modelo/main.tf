provider "aws" {
  region  = var.region
  profile = var.profile_sigla

  ignore_tags {
    keys = ["Name", "map-migrated"]
  }
}

module "amazon_mq" {
  source = "git::https://gitlab.santanderbr.corp/cpf/terraform-modules/aws-amazon-mq.git?ref=master"

  // AWS CONNECTIONS
  profile_sigla         = var.profile_sigla
  region                = var.region
  shared_account_region = var.shared_account_region
  profile_shared        = var.profile_shared

  // NAMING
  app_name          = var.app_name
  entity            = var.entity
  environment       = var.environment
  function          = var.function
  resource_sequence = var.resource_sequence

  // MQ
  engine = var.engine

  // TAGS
  tags = var.tags

  // Encrypt
  encryption_at_rest_kms_key_arn = var.encryption_at_rest_kms_key_arn

  // Network
  vpc_id     = var.vpc_id
  subnet_ids = var.subnet_ids

  amqp_port_enabled      = var.amqp_port_enabled
  mqtt_port_enabled      = var.mqtt_port_enabled
  openwire_port_enabled  = var.openwire_port_enabled
  stomp_port_enabled     = var.stomp_port_enabled
  websocket_port_enabled = var.websocket_port_enabled

}
