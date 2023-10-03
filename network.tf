data "aws_vpc" "vpc" {
  id = var.vpc_id
}

resource "aws_security_group" "this" {
  depends_on  = [data.aws_vpc.vpc]
  name        = "${local.naming}-sg"
  description = "Allow inbound traffic AmazonMQ from Security Groups and CIDRs. Allow all outbound traffic"
  vpc_id      = data.aws_vpc.vpc.id
  tags        = module.tags.tags
}

resource "aws_security_group_rule" "web_console_rule_sg" {
  depends_on               = [aws_security_group.this]
  count                    = length(var.security_groups) > 0 ? length(var.security_groups) : 0
  description              = "Allow ingress traffic to AmazonMQ Web Console from trusted Security Groups"
  type                     = "ingress"
  from_port                = 8162
  protocol                 = "tcp"
  to_port                  = 8162
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "web_console_rule" {
  depends_on        = [aws_security_group.this]
  count             = length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow ingress traffic to AmazonMQ Web Console from CIDR blocks"
  type              = "ingress"
  from_port         = 8162
  protocol          = "tcp"
  to_port           = 8162
  security_group_id = aws_security_group.this.id
  cidr_blocks       = var.allowed_cidr_blocks
}

resource "aws_security_group_rule" "open_wire_rule_sg" {
  depends_on               = [aws_security_group.this]
  count                    = var.openwire_port_enabled && length(var.security_groups) > 0 ? length(var.security_groups) : 0
  description              = "Allow ingress traffic to AmazonMQ OpenWire from trusted Security Groups"
  type                     = "ingress"
  from_port                = 61617
  protocol                 = "tcp"
  to_port                  = 61617
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "open_wire_rule" {
  depends_on        = [aws_security_group.this]
  count             = var.openwire_port_enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow ingress traffic to AmazonMQ OpenWire from CIDR blocks"
  type              = "ingress"
  from_port         = 61617
  protocol          = "tcp"
  to_port           = 61617
  security_group_id = aws_security_group.this.id
  cidr_blocks       = var.allowed_cidr_blocks
}

resource "aws_security_group_rule" "amqp_rule_sg" {
  depends_on               = [aws_security_group.this]
  count                    = var.amqp_port_enabled && length(var.security_groups) > 0 ? length(var.security_groups) : 0
  description              = "Allow ingress traffic to AmazonMQ AMQP from trusted Security Groups"
  type                     = "ingress"
  from_port                = 5671
  protocol                 = "tcp"
  to_port                  = 5671
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "amqp_rule" {
  depends_on        = [aws_security_group.this]
  count             = var.amqp_port_enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow ingress traffic to AmazonMQ AMQP from CIDR blocks"
  type              = "ingress"
  from_port         = 5671
  protocol          = "tcp"
  to_port           = 5671
  security_group_id = aws_security_group.this.id
  cidr_blocks       = var.allowed_cidr_blocks
}

resource "aws_security_group_rule" "stomp_rule_sg" {
  depends_on               = [aws_security_group.this]
  count                    = var.stomp_port_enabled && length(var.security_groups) > 0 ? length(var.security_groups) : 0
  description              = "Allow ingress traffic to AmazonMQ STOMP from trusted Security Groups"
  type                     = "ingress"
  from_port                = 61614
  protocol                 = "tcp"
  to_port                  = 61614
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "stomp_rule" {
  depends_on        = [aws_security_group.this]
  count             = var.stomp_port_enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow ingress traffic to AmazonMQ STOMP from CIDR blocks"
  type              = "ingress"
  from_port         = 61614
  protocol          = "tcp"
  to_port           = 61614
  security_group_id = aws_security_group.this.id
  cidr_blocks       = var.allowed_cidr_blocks
}

resource "aws_security_group_rule" "mqtt_rule_sg" {
  depends_on               = [aws_security_group.this]
  count                    = var.mqtt_port_enabled && length(var.security_groups) > 0 ? length(var.security_groups) : 0
  description              = "Allow ingress traffic to AmazonMQ MQTT from trusted Security Groups"
  type                     = "ingress"
  from_port                = 8883
  protocol                 = "tcp"
  to_port                  = 8883
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "mqtt_rule" {
  depends_on        = [aws_security_group.this]
  count             = var.mqtt_port_enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow ingress traffic to AmazonMQ MQTT from CIDR blocks"
  type              = "ingress"
  from_port         = 8883
  protocol          = "tcp"
  to_port           = 8883
  security_group_id = aws_security_group.this.id
  cidr_blocks       = var.allowed_cidr_blocks
}

resource "aws_security_group_rule" "wss_rule_sg" {
  depends_on               = [aws_security_group.this]
  count                    = var.websocket_port_enabled && length(var.security_groups) > 0 ? length(var.security_groups) : 0
  description              = "Allow ingress traffic to AmazonMQ WebSocket from trusted Security Groups"
  type                     = "ingress"
  from_port                = 61619
  protocol                 = "tcp"
  to_port                  = 61619
  source_security_group_id = var.security_groups[count.index]
  security_group_id        = aws_security_group.this.id
}

resource "aws_security_group_rule" "wss_rule" {
  depends_on        = [aws_security_group.this]
  count             = var.websocket_port_enabled && length(var.allowed_cidr_blocks) > 0 ? 1 : 0
  description       = "Allow ingress traffic to AmazonMQ WebSocket from CIDR blocks"
  type              = "ingress"
  from_port         = 61619
  protocol          = "tcp"
  to_port           = 61619
  security_group_id = aws_security_group.this.id
  cidr_blocks       = var.allowed_cidr_blocks
}
