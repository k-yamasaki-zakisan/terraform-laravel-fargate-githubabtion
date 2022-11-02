# data aws_route53_zone host_domain {
#   name = local.HOST_DOMAIN
# }

# resource "aws_route53_zone" "app_subdomain" {
#   name = local.APP_DOMAIN_NAME
# }

# resource "aws_route53_record" "ns_record_for_app_subdomain" {
#   name    = aws_route53_zone.app_subdomain.name
#   type    = "NS"
#   zone_id = data.aws_route53_zone.host_domain.id
#   records = [
#     aws_route53_zone.app_subdomain.name_servers[0],
#     aws_route53_zone.app_subdomain.name_servers[1],
#     aws_route53_zone.app_subdomain.name_servers[2],
#     aws_route53_zone.app_subdomain.name_servers[3],
#   ]
#   ttl = 172800
# }

# data "aws_acm_certificate" "host_domain_wc_acm" {
#   domain = "*.${local.HOST_DOMAIN}"
# }