locals {
  name = "${var.env}-${var.team}"

  firewall_endpoint_id = flatten(resource.aws_networkfirewall_firewall.aws_network_firewall.firewall_status[*].sync_states[*].attachment[*].endpoint_id)

  aws_network_firewall_endpoint_id = local.firewall_endpoint_id

}

