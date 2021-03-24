variable "aws_region" {
  type        = string
  description = "The AWS region to put the bucket into"
  default     = "us-west-1"
}

variable "site_domain" {
  type        = string
  description = "The domain name to use for the static site"
}

variable "cloudflare_zone_id" {
  type        = string
  description = "The ID of the zone that we are adding the site CNAME record to"
}