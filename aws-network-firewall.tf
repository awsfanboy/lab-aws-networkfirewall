resource "aws_networkfirewall_firewall" "aws_network_firewall" {
  name                = "${local.name}-aws-network-firewall"
  description         = "AWS Network Firewall to test the traffic"
  firewall_policy_arn = aws_networkfirewall_firewall_policy.default_policy.arn
  vpc_id              = module.inspection_vpc.vpc_id
  subnet_mapping {
    subnet_id = aws_subnet.inspection_vpc_firewall_subnet.id
  }
}


resource "aws_networkfirewall_rule_group" "default_rule_group" {
  capacity = 100
  name     = "default-stateless-rule-group"
  type     = "STATELESS"
  rule_group {
    rules_source {
      stateless_rules_and_custom_actions {
        stateless_rule {
          priority = 10
          rule_definition {
            actions = ["aws:forward_to_sfe"]
            match_attributes {
              source {
                address_definition = var.egress_vpc_cidr
              }
              source {
                address_definition = var.app_vpc_cidr
              }
            }
          }
        }
      }
    }
  }
}

# Block google.com
resource "aws_networkfirewall_rule_group" "block_google" {
  capacity = 100
  name     = "block-google"
  type     = "STATEFUL"
  rule_group {
    rule_variables {
      ip_sets {
        key = "HOME_NET"
        ip_set {
          definition = [module.app_vpc.vpc_cidr_block, module.egress_vpc.vpc_cidr_block]
        }
      }
    }
    rules_source {
      rules_source_list {
        generated_rules_type = "DENYLIST"
        target_types         = ["HTTP_HOST", "TLS_SNI"]
        targets              = [".google.com"]
      }
    }
  }
}

# Block SSH
resource "aws_networkfirewall_rule_group" "block_ssh" {
  capacity = 50
  name     = "block-ssh"
  type     = "STATEFUL"
  rule_group {
    rules_source {
      stateful_rule {
        action = "DROP"
        header {
          destination      = "ANY"
          destination_port = "ANY"
          direction        = "ANY"
          protocol         = "SSH"
          source           = "ANY"
          source_port      = "ANY"
        }
        rule_option {
          keyword  = "sid"
          settings = ["1"]
        }
      }
    }
  }

}


resource "aws_networkfirewall_firewall_policy" "default_policy" {
  name = "default-policy"
  firewall_policy {
    stateless_default_actions          = ["aws:forward_to_sfe"]
    stateless_fragment_default_actions = ["aws:forward_to_sfe"]

    stateless_rule_group_reference {
      priority     = 20
      resource_arn = aws_networkfirewall_rule_group.default_rule_group.arn

    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_google.arn
    }

    stateful_rule_group_reference {
      resource_arn = aws_networkfirewall_rule_group.block_ssh.arn
    }
  }
}

# Cloud Watch Logs
resource "aws_cloudwatch_log_group" "aws_network_firewall_alerts_logs" {
  name = "/aws/aws_network_firewall/alert"
}

resource "aws_cloudwatch_log_group" "aws_network_firewall_flow_logs" {
  name = "/aws/aws_network_firewall/flow"
}

resource "aws_networkfirewall_logging_configuration" "aws_network_firewall_alert_logs" {
  firewall_arn = aws_networkfirewall_firewall.aws_network_firewall.arn
  logging_configuration {
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.aws_network_firewall_alerts_logs.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "ALERT"
    }
    log_destination_config {
      log_destination = {
        logGroup = aws_cloudwatch_log_group.aws_network_firewall_flow_logs.name
      }
      log_destination_type = "CloudWatchLogs"
      log_type             = "FLOW"
    }
  }
}



