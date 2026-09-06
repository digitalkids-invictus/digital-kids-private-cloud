resource "render_postgres" "db" {
  name          = "persistent-postgres"
  plan          = "free"
  region        = "oregon"
  database_name = "app_db_lvqw"
  database_user = "app_user"
  version       = "15"

  lifecycle {
    prevent_destroy = true # Evita que Terraform vuelva a borrar la base de datos
  }
}

resource "render_web_service" "app" {
  name   = "docker-web-app"
  plan   = "free"
  region = "oregon"

  runtime_source = {
    docker = {
      auto_deploy     = true
      repo_url        = "https://github.com/digitalkids-invictus/digital-kids-private-cloud"
      branch          = "main"
      dockerfile_path = "./Dockerfile"
      context         = "."
    }
  }

  env_vars = {
    "DATABASE_URL" = {
      value = render_postgres.db.connection_info.external_connection_string
    }
  }

  lifecycle {
    ignore_changes = [
      maintenance_mode, # Evita que intente configurar maintenance_mode en plan free
    ]
  }
}

output "postgres_connection_string" {
  value     = render_postgres.db.connection_info.external_connection_string
  sensitive = true
}