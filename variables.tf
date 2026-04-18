variable "admin_password" {
  description = "SQL Admin Password"
  type        = string

  validation {
    condition     = length(var.admin_password) >= 8
    error_message = "Password must be at least 8 characters."
  }
}
