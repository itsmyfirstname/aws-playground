//resource "aws_wafv2_web_acl" "site" {
//  name        = "managed-acfp-example"
//  description = "Example of a managed ACFP rule."
//  scope       = "CLOUDFRONT"
//  default_action {
//    allow {}
//  }
//  visibility_config {
//   cloudwatch_metrics_enabled = false
//    metric_name                = "friendly-rule-metric-name"
//    sampled_requests_enabled   = false
//  }
//}
