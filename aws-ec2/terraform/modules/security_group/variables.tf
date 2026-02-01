variable "vpc_id" {
  type = string
}

variable "allowed_ssh_cidr" {
  description = "CIDR block allowed to access SSH (port 22). Use your IP with /32 suffix (e.g., '203.0.113.1/32'). Set to '0.0.0.0/0' only for testing."
  type        = string
  default     = "0.0.0.0/0"
}
