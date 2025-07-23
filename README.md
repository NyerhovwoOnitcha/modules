# modules

## For Both Listener Resource
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
```
{
  "0" = {
    path_pattern = ["/api/*"],
    host_header  = ["dev.example.com"],
    priority     = 100
  }
}

```
- Attach to correct listener (HTTP or HTTPS)
```
  listener_arn = var.target_group_protocol == "HTTPS" && var.certificate_arn != null ?
    aws_lb_listener.https[0].arn : aws_lb_listener.http[0].arn

```
This automatically using target_group_protocol and certificate_arn variables selects: The HTTPS listener if you're using HTTPS with a certificate, otherwise the HTTP listener.

- Set rule priority: This pulls the priority from the individual object in listener_conditions
```
  priority = each.value.priority
``` 

- Action taken when the rule matches:  When a request matches this rule, it forwards traffic to the specified target group.

```
  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb-tgt.arn
  }
```




