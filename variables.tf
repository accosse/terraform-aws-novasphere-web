variable "environment" {
  type        = string
  description = "Environnement de déploiement"

  validation {
    condition     = contains(["dev", "prod"], var.environment)
    error_message = "L'environnement doit être 'dev' ou 'prod'."
  }
}

variable "vpc_id" {
  type        = string
  description = "ID du VPC"
}

variable "subnet_ids" {
  type        = list(string)
  description = "Liste des subnets publics"
}

variable "instance_type" {
  type        = string
  description = "Type d'instance EC2"
  default     = "t2.micro"
}

variable "ami_id" {
  type        = string
  description = "ID de l'AMI à utiliser"
}

variable "app_name" {
  type        = string
  description = "Nom de l'application"
  default     = "novasphere"
}