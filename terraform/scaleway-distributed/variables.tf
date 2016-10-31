variable "organization" {
  type = "string"
  description = "Scaleway organization (access key in the interface)"
}
variable "access_key" {
  type = "string"
  description = "Scaleway access_key (token in the interface)"
}

variable "servers" {
  default = "4"
  description = "Number of servers to create"
}
variable "type" {
  type = "string"
  default = "VC1S"
  description = "Scaleway commercial type"
}

variable "ssh_private_key" {
  type = "string"
  description = "Scaleway organization private key"
}

variable "minio_access_key" {
  type = "string"
  default = "AKIAIOSFODNN7EXAMPLE"
  description = "Minio access key"
}

variable "minio_secret_key" {
  type = "string"
  default = "wJalrXUtnFEMI/K7MDENG/bPxRfiCYEXAMPLEKEY"
  description = "Minio secret key"
}
