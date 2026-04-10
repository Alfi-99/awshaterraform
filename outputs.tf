output "alb_dns_name" {
  description = "Alamat DNS untuk mengakses website"
  value       = aws_lb.alb.dns_name
}

output "ecr_repository_url" {
  description = "URL gudang Docker di ECR"
  value       = aws_ecr_repository.app_repo.repository_url
}