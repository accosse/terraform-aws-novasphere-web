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

variable "user_data" {
  type        = string
  description = "Script de démarrage des instances (en clair, le module l'encode en base64)"
  default     = ""
}

variable "instance_profile_name" {
  type        = string
  description = "Nom du profil d'instance IAM attaché aux instances"
}

variable "min_size" {
  type        = number
  description = "Nombre minimum d'instances"
  default     = 2

  validation {
    condition     = var.min_size >= 2
    error_message = "Le socle impose au moins 2 instances."
  }
}

variable "max_size" {
  type        = number
  description = "Nombre maximum d'instances"
  default     = 4
}

variable "desired_capacity" {
  type        = number
  description = "Nombre d'instances souhaité (par défaut min_size)"
  default     = null
}
