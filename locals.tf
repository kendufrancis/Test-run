locals {
    service_ports = {
    http     = 80
    https    = 443
    }
    service_protocols = {
    http     = "tcp"
    https    = "tcp"
    }
#     container_name = [ "auth-api-dev2","email-api_dev2", "lms-api_dev2","lms_console_dev2","payment_api_dev2" ]
#     task_family = [ "task_auth", "task_email", "task_lms", "task_console", "task_payment"]
#     region = local.environment == "prod" ? "us-west-2" : "us-east-1"
#     services = {
#         "task_auth" = {
#             name           = "authentication_api"
#             image          = "rc-53-4495287"
#             container_port = 3000
#         }
#         "task_email" = {
#             name           = "email-service"
#             image          = "rc-20-1ef693b"
#             container_port = 8080
#         }
#         "task_lms" = {
#             name           = "lms_api"
#             image          = "rc-242-8e5d1a8"
#             container_port = 8081
#         }
#         "task_console" = {
#             name           = "lms_console"
#             image          = "rc-507-4bd8696"
#             container_port = 8082
#         }
#         "task_payment" = {
#             name           = "payment_api"
#             image          = "rc-49-eadea73"
#             container_port = 9001
#         }
#     }
 }