# This code will create dynamically rules in AWS Wafv2 reading name, priority, IPs   
# and beyond from a CSV file. The code creates the ipset, the rules and the webacl 
# needed, will name everything accordingly.  

provider "aws" {
  region = "us-west-2" # Change this to your desired region
}

resource "aws_wafv2_ip_set" "ipset" {
  for_each = { for idx, rule in local.wafrule_details : rule.name => rule }

  name        = "ipset-${each.value.name}"
  description = each.value.description

  ip_address_version = "IPV4"
  scope              = var.ipset_scope

  addresses = [each.value.ipaddr]
}

resource "aws_wafv2_web_acl" "waf_acl" {
  name        = "web-acl-${var.web_acl_name}"
  description = "Web ACL for ${var.web_acl_name}"
  scope       = var.wafacl_scope

  default_action {
    dynamic "allow" {
      for_each = var.default_action_type == "allow" ? [1] : []

      content {}
    }

    dynamic "block" {
      for_each = var.default_action_type == "block" ? [1] : []

      content {}
    }
  }

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "WebACL-${var.web_acl_metrics}"
    sampled_requests_enabled   = true
  }

  dynamic "rule" {
    for_each = local.wafrule_details
    content {
      name     = "rule-${rule.value.name}"
      priority = rule.value.priority

      action {
        count {}
      }

      dynamic "statement" {
        for_each = rule.value != {} ? [1] : []
        content {
          byte_match_statement {
            field_to_match {
              single_header {
                name = rule.value != {} ? lower(rule.value.name) : "default-header"
              }
            }
            positional_constraint = rule.value != {} ? "STARTS_WITH" : "CONTAINS"
            search_string         = rule.value != {} ? rule.value.ipaddr : "default-ipaddr"

            text_transformation {
              priority = 0
              type     = "NONE"
            }
          }
        }
      }

      dynamic "visibility_config" {
        for_each = rule.value != {} ? [1] : []
        content {
          cloudwatch_metrics_enabled = true
          metric_name                = "WebACL-${var.web_acl_metrics}-Rule-${rule.key}"
          sampled_requests_enabled   = true
        }
      }
    }
  }
}
