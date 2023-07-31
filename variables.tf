variable "web_acl_name" {
  type        = string
  description = "Name of the AWS WAF Web ACL."
}

variable "web_acl_metrics" {
  type        = string
  description = "Metric name for the AWS WAF Web ACL."
}

variable "csv_file_path" {
  type        = string
  description = "File path of the CSV containing the rules data."
}

variable "waf_rule_name" {
  type        = string
  description = "Name of the AWS WAF rule."
}

variable "waf_rule_metrics" {
  type        = string
  description = "Metric name for the AWS WAF rule."
}





variable "rule_priorities" {
  type        = list(number)
  description = "List of rule priorities from CSV data."
  default     = []
}

variable "ipset_scope" {
  type        = string
  description = "Default scope for ipset CLOUDFRONT / REGIONAL"
}

variable "wafacl_scope" {
  type        = string
  description = "Default scope for WAF ACL CLOUDFRONT / REGIONAL"
}

locals {
  csv_data    = file(var.csv_file_path)
  csv_ips     = csvdecode(local.csv_data)
  description = "Variable to extract data from CSV"

  wafrule_details = [
    for wrd in local.csv_ips : {
      ipaddr      = wrd.ip_address
      type        = wrd.type
      name        = wrd.name
      priority    = wrd.priority
      description = wrd.description
    }
  ]

  # Rule names are case sensitive, this function will assure names in CSV field 
  # will be passed in lowercase to rules name.
  lowercase_names = {
    for rule in local.wafrule_details : rule.name => lower(rule.name)
  }

}

variable "default_action_type" {
  description = "Type of Default Action. Valid values are 'allow' or 'block'."
  type        = string
  default     = "allow" # Change this to "allow" if you want the default action to be "allow"
}

