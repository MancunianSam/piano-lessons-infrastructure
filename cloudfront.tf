locals {
  s3_origin_id                = "${local.bucket_name}.s3.eu-west-2.amazonaws.com"
  bucket_name                 = "piano-lessons-news-feed-images"
  distribution_parameter_name = "/mgmt/cloudfront/distribution"
}
resource "aws_s3_bucket" "image_bucket" {
  bucket = local.bucket_name

}

resource "aws_s3_bucket_policy" "bucket_policy" {
  bucket = local.bucket_name
  policy = templatefile("${path.module}/templates/image_bucket_policy.json.tpl", {
    bucket_arn       = aws_s3_bucket.image_bucket.arn
    distribution_arn = aws_cloudfront_distribution.images.arn
  })
}

resource "aws_cloudfront_distribution" "images" {
  enabled = true
  origin {
    domain_name              = aws_s3_bucket.image_bucket.bucket_regional_domain_name
    origin_id                = local.s3_origin_id
    origin_access_control_id = aws_cloudfront_origin_access_control.control.id
  }
  price_class = "PriceClass_100"
  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = local.s3_origin_id

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }
  viewer_certificate {
    cloudfront_default_certificate = true
  }
  restrictions {
    geo_restriction {
      restriction_type = "whitelist"
      locations        = ["GB"]
    }
  }
}

resource "aws_cloudfront_origin_access_control" "control" {
  name                              = local.s3_origin_id
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

resource "aws_ssm_parameter" "cloudfront_distribution" {
  name  = local.distribution_parameter_name
  type  = "String"
  value = aws_cloudfront_distribution.images.domain_name
}