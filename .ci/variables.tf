# ================================
# Required
# ================================

variable "api_token" {
  description = "Linode API token"
  sensitive   = true
}


# ================================
# Optional
# ================================

variable "branch" {
  description = "Git branch"
  default     = "main"
}

variable "region" {
  description = "Linode region"
  default     = "us-east"
}
