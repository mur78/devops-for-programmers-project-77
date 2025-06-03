variable "yc_token" {
  type      = string
  sensitive = true
}

variable "yc_zone" {
  type = string
}

variable "os_image" {
  type = string
}

variable "yc_folder" {
  type = string
}

variable "yc_user" {
  type = string
}

variable "db_name" {
  type      = string
  sensitive = true
}

variable "db_user" {
  type = string
}

variable "db_password" {
  type = string
}

variable "domain_name" {
  type = string
}

variable "datadog_api_key" {
  type      = string
  sensitive = true
}
variable "datadog_app_key" {
  type      = string
  sensitive = true
}

variable "datadog_url" {
  type = string
}

variable "ssh_public_key" {
  type = string
}

variable "ssh_private_key_path" {
  type = string
}
