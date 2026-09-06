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
      repo_url      = "https://github.com/digitalkids-invictus/digital-kids-private-cloud"
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