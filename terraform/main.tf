resource "render_postgres" "db" {
  name          = "persistent-postgres"
  plan          = "free"
  region        = "oregon"
  database_name = "app_db_lvqw_ybt6" # Matches the exact database name in tfstate
  database_user = "app_user"
  version       = "15"

  lifecycle {
    prevent_destroy = true
    ignore_changes  = [database_name]
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
}

output "postgres_connection_string" {
  value     = render_postgres.db.connection_info.external_connection_string
  sensitive = true
}