# WAFv2-Rules-CSV-Auto
Repository for a code will automate the creation of AWS WAFv2 Rules using CSV as input.
*This code does not consider authentication, user must decide best suited authentication method.*

The code works for WAF(version 2) rules allowing or blocking IPs, it can be ranges or unique IPs. The code will iterate trough a CSV file to get info needed for the creation of IPset and Waf rules like the IPs, the name, the priority of the rule, remember the priorities must be unique values, can't be two or more rules with the same priority number otherwise will fail. In the variable file vars.tfvars we can setup the name and other values we want. For default the variable default_action_type, which controls the default action is setup to allow, so it will allow anything to pass and the rules added will block whatever we define, the behavior, can be changed inverting the value to block, which will block the traffic and permit only what we put into the rules. This code is intended for rules based on IP. After created the web acl can be associated to the resources supporting wafv2 rules.

magic command: terraform apply -var-file=vars.tfvars -auto-approve

More detailed article: https://medium.com/@fabricio.aa.it/
