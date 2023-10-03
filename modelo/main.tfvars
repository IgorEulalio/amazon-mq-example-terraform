// AWS CONNECTIONS
profile_sigla         = "arq-dev"
region                = "sa-east-1"
profile_shared        = "arq-dev"
shared_account_region = "sa-east-1"

// NAMING VARIABLES
entity            = "sbr"
app_name          = null
function          = "crit"
environment       = "d1 | i1 | p1"
resource_sequence = 1

// TAGS VARIABLES

tags = {
  sigla             = "sigla"
  business_service  = "CI0000000000" #BUSCAR O VALOR NO CMDB
  service_component = "CI0000000000" #BUSCAR O VALOR NO CMDB
  management_level  = "SAAS"         #IAAS, CAAS, PAAS, SAAS, FAAS
  sbr_backup        = "n/a"          #(DEFAULT N/A) PREENCHER SOMENTE SE O MANAGEMENT LEVEL FOR IAAS. VALORES VÁLIDOS: AWS, AZURE, TSM, NVA
  cia               = ""             #[(a,b,c)(l,m,h)(l,m,c)]
  "cost center"     = ""
  name              = ""                                                                                     #DEV = sbr*1abrlam***brscomm001 | PRE/PRO = sbr*1abrlam***brscrit001
  tracking_code     = "DMN=DMND0000000 - PRJ=PRJ0000000 - FRE=FRE000000 - RPI=RPI0000000 - REQ=REQ000000000" #BUSCAR OS VALORES NO PORTAL DE CAPACIDADE
  provisioned_by    = "iac"                                                                                  #VALOR DEFAULT. NÃO ALTERAR!
}


host_instance_type = "mq.m5.large"
engine = {
  type    = "RabbitMQ"
  version = "3.8.23"
}

// MQ
#engine = {
#  type = "ActiveMQ"
#  version = "5.16.3"
#}  

deployment_mode            = "ACTIVE_STANDBY_MULTI_AZ"
apply_immediately          = true
auto_minor_version_upgrade = true

// NETWORK
vpc_id              = "vpc-0a42e2eb1b161cb99"
subnet_ids          = ["subnet-0087155b142884c79", "subnet-0fcd5061fb640a5da"]
allowed_cidr_blocks = ["10.84.6.0/27"]

// LOGGING
general_log_enabled = true
audit_log_enabled   = true

// Backup
maintenance_day_of_week = "SUNDAY"
maintenance_time_of_day = "03:00"
maintenance_time_zone   = "UTC"

amqp_port_enabled      = true
mqtt_port_enabled      = false
openwire_port_enabled  = false
stomp_port_enabled     = false
websocket_port_enabled = false









