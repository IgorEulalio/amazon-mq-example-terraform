provider "aws" {
  region  = var.region
  profile = var.profile_sigla

  ignore_tags {
    keys = ["Name", "map-migrated"]
  }
}

provider "aws" {
  alias   = "shared"
  region  = var.shared_account_region
  profile = var.profile_shared

  ignore_tags {
    keys = ["Name", "map-migrated"]
  }
}

locals {
  geo_regions = {
    "sa-east-1" = "abr"
    "us-east-1" = "ae1"
  }

  app_name             = var.app_name == null ? "${var.tags.sigla}brs" : var.app_name
  naming               = join("", [var.entity, var.environment, local.geo_regions[var.region], "amq", local.app_name, var.function, format("%03d", var.resource_sequence)])
  naming_kms           = join("", [var.entity, var.environment, local.geo_regions[var.region], "kms", local.app_name, var.function, format("%03d", var.resource_sequence)])
  naming_secret        = var.secret_name == null ? local.naming : var.secret_name
  naming_secret_prefix = substr(local.naming_secret, 0, 10) == "AmazonMQ_" ? local.naming_secret : "AmazonMQ_${local.naming_secret}"

  mq_admin_user_enabled = var.engine.type == "ActiveMQ"

  mq_admin_user_is_set = var.mq_admin_user != null && var.mq_admin_user != ""
  mq_admin_user        = local.mq_admin_user_is_set ? var.mq_admin_user : "mq-admin-user"

  mq_admin_password_is_set = var.mq_admin_password != null && var.mq_admin_password != ""
  mq_admin_password        = local.mq_admin_password_is_set ? var.mq_admin_password : join("", random_password.mq_admin_password.*.result)

  mq_application_user_is_set = var.mq_application_user != null && var.mq_application_user != ""
  mq_application_user        = local.mq_application_user_is_set ? var.mq_application_user : "mq-application-user"

  mq_application_password_is_set = var.mq_application_password != null && var.mq_application_password != ""
  mq_application_password        = local.mq_application_password_is_set ? var.mq_application_password : join("", random_password.mq_application_password.*.result)

  environments = {
    "d1" = "DEV" ## dev environment
    "i1" = "PRE"
    "p1" = "PRO"
  }
  environment     = local.environments[var.environment]
  confidentiality = substr(var.tags.cia, 0, 1)

  secrets_admin_user_string = {
    username = local.mq_admin_user
    password = local.mq_admin_password
  }

  secrets_application_user_string = {
    username = local.mq_application_user
    password = local.mq_application_password
  }

  encryption_at_rest_existing_kms_key_arn = var.encryption_at_rest_kms_key_arn != null && local.confidentiality == "A" ? try(data.aws_kms_key.validate_kms_by_level_A_tag_cia.0.arn, null) : try(data.aws_kms_key.kms_key.0.arn, null)
  encryption_at_rest_kms_key_arn          = var.encryption_at_rest_kms_key_arn == null ? try(aws_kms_key.key.0.arn, null) : local.encryption_at_rest_existing_kms_key_arn
  encryption_secret_kms_key_arn           = local.encryption_at_rest_kms_key_arn
  mq_logs = {
    logs = {
      "general_log_enabled" : var.general_log_enabled,
      "audit_log_enabled" : var.engine.type == "ActiveMQ" ? var.audit_log_enabled : false
    }
  }
}

data "aws_caller_identity" "profile_sigla" {}

data "aws_caller_identity" "profile_shared" {
  provider = aws.shared
}

module "tags" {
  source = "git::https://gitlab.santanderbr.corp/cpf/terraform-modules/tag?ref=master"
  tags   = var.tags
}


resource "random_password" "mq_admin_password" {
  count   = local.mq_admin_user_enabled && !local.mq_admin_password_is_set ? 1 : 0
  length  = 16
  special = false
}

resource "random_password" "mq_application_password" {
  count   = !local.mq_application_password_is_set ? 1 : 0
  length  = 16
  special = false
}

resource "aws_secretsmanager_secret" "admin_user_secret" {
  count                   = local.mq_admin_user_enabled ? 1 : 0
  name                    = "${local.naming_secret_prefix}_admin_user"
  recovery_window_in_days = 0
  kms_key_id              = local.encryption_secret_kms_key_arn
  tags                    = module.tags.tags
}

resource "aws_secretsmanager_secret_version" "admin_user_secret_version" {
  count         = local.mq_admin_user_enabled ? 1 : 0
  secret_id     = aws_secretsmanager_secret.admin_user_secret.0.id
  secret_string = jsonencode(local.secrets_admin_user_string)
}

resource "aws_secretsmanager_secret" "application_user_secret" {
  name                    = "${local.naming_secret_prefix}_application_user"
  recovery_window_in_days = 0
  kms_key_id              = local.encryption_secret_kms_key_arn
  tags                    = module.tags.tags
}

resource "aws_secretsmanager_secret_version" "application_user_secret_version" {
  secret_id     = aws_secretsmanager_secret.application_user_secret.id
  secret_string = jsonencode(local.secrets_application_user_string)
}

resource "aws_mq_broker" "amazon_mq_broker" {

  broker_name = local.naming

  dynamic "configuration" {
    for_each = aws_mq_configuration.amazon_mq_broker_config
    content {
      id       = configuration.value.id
      revision = configuration.value.latest_revision
    }
  }

  engine_type        = var.engine.type
  engine_version     = var.engine.version
  host_instance_type = var.host_instance_type
  security_groups    = [aws_security_group.this.id]
  deployment_mode    = var.deployment_mode
  apply_immediately  = var.apply_immediately
  subnet_ids         = var.subnet_ids

  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  publicly_accessible        = false
  #storage_type = "efs" / "ebs" # - (Optional) Storage type of the broker. For engine_type ActiveMQ, the valid values are efs and ebs, and the AWS-default is efs. For engine_type RabbitMQ, only ebs is supported. When using ebs, only the mq.m5 broker instance type family is supported.

  # NOTE: Omit logs block if both general and audit logs disabled:
  # https://github.com/hashicorp/terraform-provider-aws/issues/18067
  dynamic "logs" {
    for_each = {
      for logs, type in local.mq_logs : logs => type
      if type.general_log_enabled || type.audit_log_enabled
    }
    content {
      general = logs.value["general_log_enabled"]
      audit   = logs.value["audit_log_enabled"] # only valid to ActiveMQ
    }
  }

  maintenance_window_start_time {
    day_of_week = var.maintenance_day_of_week
    time_of_day = var.maintenance_time_of_day
    time_zone   = var.maintenance_time_zone
  }

  dynamic "user" {
    for_each = local.mq_admin_user_enabled ? ["true"] : []
    content {
      username       = local.mq_admin_user
      password       = local.mq_admin_password
      groups         = ["admin"]
      console_access = true
    }
  }

  user {
    username = local.mq_application_user
    password = local.mq_application_password
  }

  encryption_options {
    kms_key_id        = local.encryption_at_rest_kms_key_arn
    use_aws_owned_key = false
  }

  depends_on = [
    aws_secretsmanager_secret.admin_user_secret,
    aws_secretsmanager_secret.application_user_secret
  ]

  tags = module.tags.tags
}

resource "aws_mq_configuration" "amazon_mq_broker_config" {
  count = var.engine.type == "ActiveMQ" ? 1 : 0

  description    = "${local.naming} Configuration"
  name           = "${local.naming}-config"
  engine_type    = var.engine.type
  engine_version = var.engine.version
  data           = <<-DATA
    <?xml version="1.0" encoding="UTF-8" standalone="yes"?>
    <broker xmlns="http://activemq.apache.org/schema/core">
      <plugins>
        <forcePersistencyModeBrokerPlugin persistenceFlag="true"/>
        <statisticsBrokerPlugin/>
        <timeStampingBrokerPlugin ttlCeiling="86400000" zeroExpirationOverride="86400000"/>
      </plugins>
    </broker>
    DATA
  tags           = module.tags.tags
}