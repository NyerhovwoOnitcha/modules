# terraform-aws-alb

Terraform module to provision an Application Load Balancer (ALB) on AWS with support for HTTPS, listener rules, and flexible condition-based routing.

---

## Features

- Creates an ALB (Application Load Balancer)
- Supports HTTPS and HTTP listeners
- Redirects HTTP to HTTPS automatically
- Dynamically creates listener rules with support for:
  - Host headers
  - Path patterns
  - HTTP headers
- Exposes target group for consumer-defined attachments
- Supports tagging
- Works with Terraform Cloud remote workspaces using tags

---

## Usage

module "alb" {
  source = "path/to/terraform-aws-alb"

  lb_name               = var.lb_name
  target_type           = var.target_type
  load_balancer_type    = var.load_balancer_type
  target_group_port     = var.target_group_port
  target_group_protocol = var.target_group_protocol
  certificate_arn       = var.certificate_arn
  health_check_path     = var.health_check_path
  tags                  = var.tags
  environment           = var.environment
  module_name           = "alb"

  loadbalancer_target   = var.loadbalancer_target

  enable_access_logs    = var.enable_access_logs
  access_logs_bucket    = var.access_logs_bucket
  access_logs_prefix    = var.access_logs_prefix

  alb_sg                = module.alb_security_group.alb_sg_id
  vpc_id                = module.vpc.vpc_id
  public_subnets        = module.vpc.public_subnets

  interval              = var.interval
  healthy_threshold     = var.healthy_threshold
  unhealthy_threshold   = var.unhealthy_threshold
  timeout               = var.timeout

  listener_conditions = [
    {
      path_pattern = ["/api/*"]
      host_header  = ["dev.example.com"]
      priority     = 100
    },
    {
      path_pattern = ["/admin/*"]
      http_header = {
        name   = "X-Env"
        values = ["dev"]
      }
      priority = 101
    }
  ]
}

## Inputs

| Name                    | Description                                                                        | Type           | Default         | Required |
| ----------------------- | ---------------------------------------------------------------------------------- | -------------- | --------------- | -------- |
| `lb_name`               | Name of the load balancer                                                          | `string`       | `null`          |  Yes    |
| `target_type`           | Target type for the target group (`instance`, `ip`, or `lambda`)                   | `string`       | `null`          |  Yes    |
| `load_balancer_type`    | Type of load balancer (`application` or `network`)                                 | `string`       | `"application"` |  Yes    |
| `target_group_port`     | Port on which targets receive traffic                                              | `number`       | `80`            |  Yes    |
| `target_group_protocol` | Protocol for routing traffic to targets (`HTTP` or `HTTPS`)                        | `string`       | `"HTTP"`        |  Yes    |
| `certificate_arn`       | ARN of the SSL certificate for HTTPS listener                                      | `string`       | `null`          |  No     |
| `health_check_path`     | The destination for the health check request                                       | `string`       | `"/"`           |  Yes    |
| `tags`                  | A map of tags to assign to resources                                               | `map(string)`  | `{}`            | Yes    |
| `environment`           | Environment name (e.g., `dev`, `staging`, `prod`)                                  | `string`       | `null`          | Yes    |
| `module_name`           | Name of this module (used for tagging)                                             | `string`       | `"alb"`         |  Yes    |
| `loadbalancer_target`   | Optional override for default target group attachment                              | `string`       | `null`          |  No     |
| `enable_access_logs`    | Enable access logging for the ALB                                                  | `bool`         | `false`         |  No     |
| `access_logs_bucket`    | S3 bucket name for storing access logs                                             | `string`       | `null`          |  No     |
| `access_logs_prefix`    | Prefix within the S3 bucket for log storage                                        | `string`       | `null`          |  No     |
| `alb_sg`                | Security group ID to associate with the ALB                                        | `string`       | `null`          |  Yes    |
| `vpc_id`                | VPC ID where the ALB is deployed                                                   | `string`       | `null`          |  Yes    |
| `public_subnets`        | List of subnet IDs for the ALB                                                     | `list(string)` | `[]`            |  Yes    |
| `interval`              | Health check interval in seconds                                                   | `number`       | `30`            |  No     |
| `healthy_threshold`     | Number of successful health checks before a target is considered healthy           | `number`       | `3`             |  No     |
| `unhealthy_threshold`   | Number of failed checks before target is considered unhealthy                      | `number`       | `3`             |  No     |
| `timeout`               | Timeout in seconds for health checks                                               | `number`       | `5`             |  No     |
| `listener_conditions`   | List of listener rules with priority and optional path/host/http header conditions | `list(object)` | `[]`            |  Yes    |

## Outputs
| Name                 | Description                                                             |
| -------------------- | ----------------------------------------------------------------------- |
| `alb_arn`            | ARN of the created Application Load Balancer                            |
| `alb_dns_name`       | DNS name of the load balancer                                           |
| `alb_zone_id`        | The canonical hosted zone ID of the ALB                                 |
| `target_group_arn`   | ARN of the target group associated with the ALB                         |
| `https_listener_arn` | ARN of the HTTPS listener (if created)                                  |
| `http_listener_arn`  | ARN of the HTTP listener (if created, usually for redirection to HTTPS) |














## Short Note TO Understanding the Resource Code Blocks


### For Both Listener Resource
**Note:**  
The count argument is Terraform’s way of conditionally creating resources.

- Interpretation:
    - count = 1 → create this resource

    - count = 0 → skip it

### For HTTPS:

```
count = var.target_group_protocol == "HTTPS" && var.certificate_arn != null ? 1 : 0
```
**Means: Only create the HTTPS listener if protocol is HTTPS and a certificate is provided.**

### For HTTP redirect:
```
count = var.target_group_protocol == "HTTPS" ? 1 : 0
```
**Means: Only create HTTP listener (on port 80) if protocol is HTTPS — so it can redirect.**

### This setup ensures that:

- If protocol is HTTP, only an HTTP listener (port 80) is created.

- If protocol is HTTPS, both:

- An HTTPS listener (port 443)

- An HTTP listener that redirects to HTTPS (port 80)

## For Listener Rule Resource
LBs can have multiple listeners and these listeners can have multiple rules that route traffic based on conditions like:
- path pattern (/api/*)

- host header (api.example.com)

- http header (e.g., x-app-version: v1)

Each listener rule matches incoming requests against the conditions we set, and if there's a match, it forwards the traffic to the appropriate target group. We want to set these conditions and make them as flexible i.e If either path OR host OR header match, forward to target group.

```h
  count = length(var.listener_conditions) > 0 ? 1 : 0
```
- Count is again used to conditionally create resources. Means only create this rule if at least one listener condition is defined. It is dynamically skipped if no conditions are set.  

- Loop through the listener conditions:
```
  for_each = {
    for idx, cond in var.listener_conditions :
    "${idx}" => cond
  }

```
This takes the listener_conditions list (defined in variables file) and turns it into a map like below. Thus dynamically creating multiple rules, one per condition.
```h
{
  "0" = {
    path_pattern = ["/api/*"],
    host_header  = ["dev.example.com"],
    priority     = 100
  }
}

```
- Attach to correct listener (HTTP or HTTPS)
```h
  listener_arn = var.target_group_protocol == "HTTPS" && var.certificate_arn != null ?
    aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn

```
This automatically using target_group_protocol and certificate_arn variables selects: The HTTPS listener if you're using HTTPS with a certificate, otherwise the HTTP listener.

- Set rule priority: This pulls the priority from the individual object in listener_conditions
```h
  priority = each.value.priority
``` 

- Action taken when the rule matches:  When a request matches this rule, it forwards traffic to the specified target group.

```h
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tgt.arn
  }
```

- Dynamic block for conditions: this wraps the object in a list to allow using dynamic nested blocks. You're now about to define the conditions (match criteria) for each rule.

```H
  dynamic "condition" {
    for_each = [each.value]

```

- Path pattern condition
```H
      dynamic "path_pattern" {
        for_each = lookup(condition.value, "path_pattern", [])
        content {
          values = path_pattern.value
        }
      }
```
This pulls the path_pattern from listener_conditions if it's defined, e.g.:

```
path_pattern = ["/api/*"]

MATCHES request URLs like `https://dev.example.com/api/users`
```
- Host header condition
```H
      dynamic "host_header" {
        for_each = lookup(condition.value, "host_header", [])
        content {
          values = host_header.value
        }
      }

```
e.g : `host_header = ["dev.example.com"]` ensures the rule applies only for this domain or subdomain.

- HTTP header condition: This checks if an http_header object is provided:
```h
      dynamic "http_header" {
        for_each = lookup(condition.value, "http_header", {}) == {} ? [] : [lookup(condition.value, "http_header", {})]
        content {
          http_header {
            name   = http_header.value.name
            values = http_header.value.values
          }
        }
      }

```
e.g
```
http_header = {
  name   = "X-Env"
  values = ["dev"]
}

```

IN A NUTSHELL, the example below shows the listener conditions if provided are rendered.

```
listener conditions = [
    {
        path_pattern = ["/api/*"]
        host_header  = ["dev.example.com"]
        priority     = 100
    },
    {
        path_pattern = ["/admin/*"]
        http_header = {
            name   = "X-Env"
            values = ["dev"]
        }
        priority = 101
    }
]
```

                    WILL BE RENDERED into 2 rules:

```
# RULE 1
resource "aws_lb_listener_rule" "lb_listener_rules"["0"] {
  listener_arn = "arn:aws:elbv2:...:listener/https"
  priority     = 100

  action {
    type             = "forward"
    target_group_arn = "arn:aws:elbv2:...:targetgroup/my-tg"
  }

  condition {
    path_pattern {
      values = ["/api/*"]
    }
  }

  condition {
    host_header {
      values = ["dev.example.com"]
    }
  }
}

This matches host Path + Header. it matches:

path = /api/ and Hostname = dev.example.com  > Forwards traffic to the outlined target

```
```
# RULE 2
resource "aws_lb_listener_rule" "lb_listener_rules"["1"] {
  listener_arn = "arn:aws:elbv2:...:listener/https"
  priority     = 101

  action {
    type             = "forward"
    target_group_arn = "arn:aws:elbv2:...:targetgroup/my-tg"
  }

  condition {
    path_pattern {
      values = ["/admin/*"]
    }
  }

  condition {
    http_header {
      http_header {
        name   = "X-Env"
        values = ["dev"]
      }
    }
  }
}

Matches Path + Custom HTTP Header

Path = /admin/* AND Header X-Env=dev	Forward to target group

```
**Note: Wildcards can also be used**