variable "tags" {
  type    = map(string)
  default = {}
}


variable "alb_sg" {
  description = "ALB security group"
}

variable "lb_name" {
  type        = string
  description = "Load balancer name"
}


variable "target_type"{
    type        = string
    description = "Target group resource type"
}

variable "load_balancer_type" {
  type        = string
  default     = "application"
  description = "Type of load balancer, e.g., application, network"
}

variable "target_group_port" {
  type        = number
  default     = 443
  description = "Port for the target group"
}

variable "target_group_protocol" {
  description = "Protocol for the target group and listener"
  type        = string
  default     = "HTTP" # or "HTTPS"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for HTTPS listener"
  type        = string
  default     = null
}

variable "target_type" {
  type        = string
  default     = "instance"
  description = "Type of target for the target group, e.g., instance, ip"
}

variable "health_check_path" {
  type        = string
  default     = "/healthstatus"
  description = "Health check path for the target group"
}

variable "public_subnets" {
  type        = list(string)
  description = "List of public subnet IDs"
}


variable "vpc_id" {
  description = "vpc id"
}


variable "loadbalancer_target" {
    description = " target group name"
  
}

# allows flexible rules like:(Match a path (/api/*)), (Match a host (app.example.com)),Match a header (e.g., X-Env = staging)

variable "listener_conditions" {
  type = list(object({
    path_pattern = optional(list(string))
    host_header  = optional(list(string))
    http_header  = optional(object({
      name   = string
      values = list(string)
    }))
  }))

variable "listener_conditions" {
  type = list(object({
    priority     = number
    path_pattern = optional(list(string))
    host_header  = optional(list(string))
    http_header  = optional(object({
      name   = string
      values = list(string)
    }))
  }))
  description = "Listener rule conditions"
  default     = []
}


  description = "List of listener rule conditions"
  default     = []
}



variable "enable_access_logs" {
  type        = bool
  description = "Enable ALB access logs"
  default     = false
}

variable "access_logs_bucket" {
  type        = string
  description = "S3 bucket for ALB access logs"
  default     = ""
}

variable "access_logs_prefix" {
  type        = string
  description = "Prefix for ALB access logs"
  default     = ""
}


variable "tags" {
  type        = map(string)
  description = "A map of tags to apply to resources"
  default     = {}
}

variable "environment" {
  type        = string
  description = "The environment for this deployment (e.g., dev, staging, prod)"
}

variable "module_name" {
  type        = string
  description = "Name of the module"
  default     = "alb"
}

variable "interval" {
  type        = number
  description = "Health check interval in seconds"
  default     = 30
}

variable "healthy_threshold" {
  type        = number
  description = "Number of consecutive successful health checks required to consider the target healthy"
  default     = 5
}

variable "unhealthy_threshold" {
  type        = number
  description = "Number of consecutive failed health checks required to consider the target unhealthy"
  default     = 2
}

variable "timeout" {
  type        = number
  description = "Timeout for health checks in seconds"
  default     = 5
}

