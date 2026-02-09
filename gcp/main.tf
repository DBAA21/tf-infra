# 1. Create VPC (Custom Mode)
resource "google_compute_network" "vpc" {
  name                    = var.vpc_name
  auto_create_subnetworks = false # Critical: disable auto subnet creation
  routing_mode            = "REGIONAL"
}

# 2. Create Subnets (3 Public + 3 Private = 6 total)
# In GCP, subnets are regional, but we create 6 to match AWS structure
resource "google_compute_subnetwork" "subnets" {
  count         = length(var.subnet_cidrs)
  name          = "${var.vpc_name}-subnet-${count.index + 1}"
  ip_cidr_range = var.subnet_cidrs[count.index]
  region        = var.region
  network       = google_compute_network.vpc.id
}

# 3. Create Route (Allow Internet Access for Public Subnets)
# Target: 0.0.0.0/0 -> Default Internet Gateway
resource "google_compute_route" "public_internet_access" {
  name             = "${var.vpc_name}-public-route"
  dest_range       = "0.0.0.0/0"
  network          = google_compute_network.vpc.id
  next_hop_gateway = "default-internet-gateway"
  priority         = 1000
}

# 4. Firewall Rule: Allow Web/SSH Traffic
resource "google_compute_firewall" "allow_web" {
  name    = "${var.vpc_name}-allow-web"
  network = google_compute_network.vpc.id

  allow {
    protocol = "tcp"
    ports    = ["80", "443", "22", "8080"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags   = ["webapp"] # VMs with this tag will allow traffic
}

# 5. Firewall Rule: Deny All Other Traffic (Explicit)
resource "google_compute_firewall" "deny_all" {
  name     = "${var.vpc_name}-deny-all"
  network  = google_compute_network.vpc.id
  priority = 65534 # Low priority (higher number = lower priority)

  deny {
    protocol = "all"
  }

  source_ranges = ["0.0.0.0/0"]
}