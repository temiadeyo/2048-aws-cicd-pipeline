output "ecr_repository_url" {
  description = "ECR repository URL"
  value       = aws_ecr_repository.game.repository_url
}

output "ecs_cluster_name" {
  description = "ECS cluster name"
  value       = aws_ecs_cluster.game.name
}

output "ecs_service_name" {
  description = "ECS service name"
  value       = aws_ecs_service.game.name
}

output "load_balancer_url" {
  description = "Load balancer URL"
  value = "http://${aws_lb.main.dns_name}"
}
