terraform {
  required_version = ">= 1.0"
  required_providers {
    render = {
      source  = "render-oss/render"
      version = "~> 1.3.0"
    }
  }
}

provider "render" {
  api_key  = var.render_api_key
  owner_id = var.render_owner_id
}

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

resource "render_postgres" "db" {
  name          = "persistent-postgres"
  plan          = "free"
  region        = "oregon"
  database_name = "app_db"
  database_user = "app_user"
  version       = "15"
}

resource "render_web_service" "app" {
  name   = "docker-web-app"
  plan   = "free"
  region = "oregon"

  runtime_source = {
    native_runtime = {
      auto_deploy   = true
      build_command = ""
      runtime       = "docker"
      
      # FIX: Se requiere la URL del repositorio y la rama 
      # para que Render sepa de dónde obtener el Dockerfile
      repo_url      = "https://github.com/TU_USUARIO/TU_REPOSITORIO"
      branch        = "main"
    }
  }

  env_vars = {
    "DATABASE_URL" = {
      value = render_postgres.db.connection_info.external_connection_string
    }
  }
}

output "postgres_connection_string" {
  value     = render_postgres.db.connection_info.external_connection_string
  sensitive = true
}