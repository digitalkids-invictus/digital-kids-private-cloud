variable "render_api_key" {
  type        = string
  description = "API Key de Render"
  sensitive   = true
}

variable "render_owner_id" {
  type        = string
  description = "User ID o Team ID de la cuenta en Render"
  sensitive   = true
}