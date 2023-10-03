// AWS CONNECTIONS
variable "profile_sigla" {
  description = "(Required) AWS Profile for Sigla/Channel Account."
  type        = string
}

variable "region" {
  description = "(Optional) Region where the resource will be launched."
  type        = string
  default     = "sa-east-1"
  validation {
    condition     = contains(["sa-east-1", "us-east-1"], var.region)
    error_message = "The current support values are sa-east-1 and us-east-1."
  }
}

variable "shared_account_region" {
  type        = string
  description = "(Optional) Shared account region. Will use this account kms."
  default     = "sa-east-1"
}

variable "profile_shared" {
  description = "(Required) AWS Profile for Shared Account."
  type        = string
}

// NAMING VARIABLES
variable "entity" {
  description = "(Optional) Santander entity code. Used for Naming. (3 characters)"
  type        = string
  default     = "sbr"
}

variable "app_name" {
  description = "(Optional) App acronym of the resource. Used for Naming. (6 characters) "
  type        = string
  default     = null
}

variable "function" {
  description = "(Optional) App function of the resource. Used for Naming. (4 characters) "
  type        = string
  default     = "comm"
  validation {
    condition     = contains(["comm", "crit"], var.function)
    error_message = "The current supported values are comm and crit."
  }
}

variable "environment" {
  description = "(Required) Santander environment code. Used for Naming. (2 characters) "
  type        = string
  validation {
    condition     = contains(["d1", "i1", "p1"], var.environment)
    error_message = "The current support values are d1, i1 or p1."
  }
}

variable "resource_sequence" {
  description = "(Required) Sequence number of the resource. If you have more than one resource, send the sequence accordingly so that names dont clash."
  type        = number
}

// TAGS VARIABLES
variable "tags" {
  description = "(Requires) Tags as defined by Global: https://confluence.alm.europe.cloudcenter.corp/x/XEGqCg"
  type        = map(string)
}

// Encrypt
variable "encryption_at_rest_kms_key_arn" {
  description = "(Optional) You may specify a KMS key short ID or ARN (it will always output an ARN) to use for encrypting your data at rest. Tag CIA confidentiality Level A KMS ARN required."
  type        = string
  default     = null
}

variable "host_instance_type" {
  description = "(Required) Host instance type and size."
  type        = string
  default     = "mq.t3.micro"

  validation {
    condition     = contains(["mq.t3.micro", "mq.m5.large", "mq.m5.xlarge", "mq.m5.2xlarge", "mq.m5.4xlarge"], var.host_instance_type)
    error_message = "The host instance type is invalid. Valid instances are mq.t3.micro, mq.m5.large, mq.m5.xlarge, mq.m5.2xlarge, mq.m5.4xlarge."
  }
}

variable "engine" {
  description = "(Required) Mq engine parameters. For version, refer to Readme.md."
  type = object({
    version = string
    type    = string
  })

  validation {
    condition     = contains(["ActiveMQ", "RabbitMQ"], var.engine.type)
    error_message = "Engine type is invalid. Valid options are ActiveMQ and RabbitMQ."
  }
}

variable "secret_name" {
  description = "(Optional) Name of the secret on secret manager to save user and password."
  type        = string
  default     = null
}

variable "deployment_mode" {
  description = "(Optional) Deployment mode of the broker. Valid values are SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, and CLUSTER_MULTI_AZ."
  type        = string
  default     = "SINGLE_INSTANCE"
  validation {
    condition     = contains(["SINGLE_INSTANCE", "ACTIVE_STANDBY_MULTI_AZ", "CLUSTER_MULTI_AZ"], var.deployment_mode)
    error_message = "Deployment Mode is invalid. Valid values are SINGLE_INSTANCE, ACTIVE_STANDBY_MULTI_AZ, and CLUSTER_MULTI_AZ."
  }
}

variable "apply_immediately" {
  description = "(Optional) Specifies whether any broker modifications are applied immediately, or during the next maintenance window."
  type        = bool
  default     = true
}

variable "auto_minor_version_upgrade" {
  description = "(Optional) Whether to automatically upgrade to new minor versions of brokers as Amazon MQ makes releases available."
  type        = bool
  default     = true
}

// NETWORK
variable "vpc_id" {
  description = "(Required) Vpc id where the resource will be launched."
  type        = string
}

variable "subnet_ids" {
  description = "(Required) Subnet IDs for Client Broker."
  type        = list(string)
}

// LOGGING
variable "general_log_enabled" {
  description = "Enables general logging via CloudWatch."
  type        = bool
  default     = true
}

variable "audit_log_enabled" {
  description = "Enables audit logging. User management action made using JMX or the ActiveMQ Web Console is logged, only valid to ActiveMQ engine."
  type        = bool
  default     = true
}

variable "mq_admin_user" {
  type        = string
  default     = null
  description = "Admin username"
}

variable "mq_admin_password" {
  type        = string
  default     = null
  description = "Admin password"
}

variable "mq_application_user" {
  type        = string
  default     = null
  description = "Application username"
}

variable "mq_application_password" {
  type        = string
  default     = null
  description = "Application password"
}

variable "allowed_cidr_blocks" {
  description = "(Optional) List of CIDR blocks to be allowed to connect to the cluster"
  type        = list(string)
  default     = []
}

variable "security_groups" {
  type        = list(string)
  default     = []
  description = "(Optional) List of security group IDs to be allowed to connect to the cluster"
}

variable "maintenance_day_of_week" {
  type        = string
  default     = "SUNDAY"
  description = "The maintenance day of the week. e.g. MONDAY, TUESDAY, or WEDNESDAY"
}

variable "maintenance_time_of_day" {
  type        = string
  default     = "03:00"
  description = "The maintenance time, in 24-hour format. e.g. 02:00"
}

variable "maintenance_time_zone" {
  type        = string
  default     = "UTC"
  description = "The maintenance time zone, in either the Country/City format, or the UTC offset format. e.g. CET"
}

variable "amqp_port_enabled" {
  description = "add rule in security group to allow port traffic via AMQP."
  type        = bool
  default     = false
}

variable "mqtt_port_enabled" {
  description = "add rule in security group to allow port traffic via MQTT."
  type        = bool
  default     = false
}

variable "openwire_port_enabled" {
  description = "add rule in security group to allow port traffic via OpenWire."
  type        = bool
  default     = false
}

variable "stomp_port_enabled" {
  description = "add rule in security group to allow port traffic via STOMP."
  type        = bool
  default     = false
}

variable "websocket_port_enabled" {
  description = "add rule in security group to allow port traffic via WebSocket."
  type        = bool
  default     = false
}

