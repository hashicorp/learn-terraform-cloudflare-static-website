provider "aws" {
  region = var.aws_region
}

provider "cloudflare" {}

resource "aws_s3_bucket" "site" {
  bucket = var.site_domain
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "index.html"
  }
}

resource "aws_s3_bucket" "www" {
  bucket = "www.${var.site_domain}"
  acl    = "private"
  policy = ""

  website {
    redirect_all_requests_to = "https://${var.site_domain}"
  }
}

resource "aws_s3_bucket_policy" "public_read" {
  bucket = aws_s3_bucket.site.id
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid       = "PublicReadGetObject"
        Effect    = "Allow"
        Principal = "*"
        Action    = "s3:GetObject"
        Resource = [
          aws_s3_bucket.site.arn,
          "${aws_s3_bucket.site.arn}/*",
        ]
      },
    ]
  })
}

data "cloudflare_zones" "domain" {
  filter {
    name = var.site_domain
  }
}

resource "cloudflare_record" "site_cname" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = var.site_domain
  value   = aws_s3_bucket.site.website_endpoint
  type    = "CNAME"

  ttl     = 1
  proxied = true
}

resource "cloudflare_record" "www" {
  zone_id = data.cloudflare_zones.domain.zones[0].id
  name    = "www"
  value   = var.site_domain
  type    = "CNAME"

  ttl     = 1
  proxied = true
}