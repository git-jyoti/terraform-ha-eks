resource "aws_globalaccelerator_accelerator" "this" {
  name            = "${var.project_name}-accelerator"
  ip_address_type = "IPV4"
  enabled         = true

  attributes {
    flow_logs_enabled = false
  }

  tags = var.tags
}

resource "aws_globalaccelerator_listener" "this" {
  accelerator_arn = aws_globalaccelerator_accelerator.this.id
  client_affinity = "SOURCE_IP"
  protocol        = "TCP"

  port_range {
    from_port = 80
    to_port   = 80
  }

  port_range {
    from_port = 443
    to_port   = 443
  }
}

resource "aws_globalaccelerator_endpoint_group" "region_a" {
  listener_arn = aws_globalaccelerator_listener.this.id
  endpoint_group_region = var.region_a

  endpoint_configuration {
    endpoint_id = var.alb_arn_a
    weight      = 100
  }
}

resource "aws_globalaccelerator_endpoint_group" "region_b" {
  listener_arn = aws_globalaccelerator_listener.this.id
  endpoint_group_region = var.region_b

  endpoint_configuration {
    endpoint_id = var.alb_arn_b
    weight      = 100
  }
}
