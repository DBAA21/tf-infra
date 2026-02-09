output "vpc_name" {
  description = "Name of the VPC network"
  value       = google_compute_network.vpc.name
}

output "vpc_id" {
  description = "ID of the VPC network"
  value       = google_compute_network.vpc.id
}

output "subnet_names" {
  description = "Names of all subnets"
  value       = google_compute_subnetwork.subnets[*].name
}

output "subnet_cidrs" {
  description = "CIDR ranges of all subnets"
  value       = google_compute_subnetwork.subnets[*].ip_cidr_range
}