############################################################
# INTERNAL USER AND SCHEMA CONFIGURATION
############################################################

# Internal user
resource "postgresql_role" "mm_cloud" {
  depends_on = [
    module.mattermost_postgres,
    data.azurerm_key_vault_secret.postgres_internal_user,
    data.azurerm_key_vault_secret.postgres_internal_password
  ]

  provider    = postgresql.mattermost
  name        = data.azurerm_key_vault_secret.postgres_internal_user.value
  login       = true
  password    = data.azurerm_key_vault_secret.postgres_internal_password.value
  superuser   = false
  create_role = false
  inherit     = false

  search_path = [var.db_internal_schema_name]
}

# Restrict database connect from PUBLIC
resource "postgresql_grant" "revoke_public_connect" {
  depends_on = [
    module.mattermost_postgres,
    data.azurerm_key_vault_secret.postgres_internal_user,
    data.azurerm_key_vault_secret.postgres_internal_password
  ]

  provider    = postgresql.mattermost
  database    = var.database_names[0]
  role        = "public"
  object_type = "database"
  privileges  = []
}

# Grant database connect to internal user
resource "postgresql_grant" "mm_cloud_connect" {
  depends_on = [
    module.mattermost_postgres,
    data.azurerm_key_vault_secret.postgres_internal_user,
    data.azurerm_key_vault_secret.postgres_internal_password
  ]

  provider    = postgresql.mattermost
  database    = var.database_names[0]
  role        = postgresql_role.mm_cloud.name
  object_type = "database"
  privileges  = ["CONNECT"]
}

# Lock down public schema
resource "postgresql_grant" "public_schema_lockdown" {
  depends_on = [
    module.mattermost_postgres,
    data.azurerm_key_vault_secret.postgres_internal_user,
    data.azurerm_key_vault_secret.postgres_internal_password
  ]

  provider    = postgresql.mattermost
  database    = var.database_names[0]
  role        = "public"
  schema      = "public"
  object_type = "schema"
  privileges  = []
}

# Create internal schema
resource "postgresql_schema" "mattermost_internal" {
  depends_on = [
    module.mattermost_postgres,
    data.azurerm_key_vault_secret.postgres_internal_user,
    data.azurerm_key_vault_secret.postgres_internal_password
  ]

  provider = postgresql.mattermost
  name     = postgresql_role.mm_cloud.search_path[0]
  owner    = postgresql_role.mm_cloud.name
  database = var.database_names[0]
}

# Grant internal user full access to its schema
resource "postgresql_grant" "mm_cloud_schema_access" {
  depends_on = [
    module.mattermost_postgres,
    data.azurerm_key_vault_secret.postgres_internal_user,
    data.azurerm_key_vault_secret.postgres_internal_password
  ]

  provider    = postgresql.mattermost
  database    = var.database_names[0]
  role        = postgresql_role.mm_cloud.name
  schema      = postgresql_schema.mattermost_internal.name
  object_type = "schema"
  privileges  = ["USAGE", "CREATE"]
}

# # Ensure external user cannot access internal schema
# resource "postgresql_grant" "mm_external_no_internal" {
#   database    = var.database_names[0]
#   role        = postgresql_role.mm_external.name
#   schema      = postgresql_schema.mattermost_internal.name
#   object_type = "schema"
#   privileges  = []
# }



############################################################
# EXTERNAL USER AND SCHEMA CONFIGURATION
############################################################

# # External user
# resource "postgresql_role" "mm_external" {
#   name       = azurerm_key_vault_secret.postgres_external_user.value
#   login      = true
#   password   = azurerm_key_vault_secret.postgres_external_password.value
#   superuser  = false
#   createdb   = false
#   create_role = false
#   inherit    = false

#   search_path = [var.db_external_schema_name]
# }

# # Grant database connect to external user
# resource "postgresql_grant" "mm_external_connect" {
#   database    = var.database_names[0]
#   role        = postgresql_role.mm_external.name
#   object_type = "database"
#   privileges  = ["CONNECT"]
# }

# # Create external schema
# resource "postgresql_schema" "mattermost_external" {
#   name     = postgresql_role.mm_external.search_path[0]
#   owner    = postgresql_role.mm_external.name
#   database = var.database_names[0]
# }

# # Grant external user full access to its schema
# resource "postgresql_grant" "mm_external_schema_access" {
#   database    = var.database_names[0]
#   role        = postgresql_role.mm_external.name
#   schema      = postgresql_schema.mattermost_external.name
#   object_type = "schema"
#   privileges  = ["USAGE", "CREATE"]
# }

# # Ensure internal user cannot access external schema
# resource "postgresql_grant" "mm_cloud_no_external" {
#   database    = var.database_names[0]
#   role        = postgresql_role.mm_cloud.name
#   schema      = postgresql_schema.mattermost_external.name
#   object_type = "schema"
#   privileges  = []
# }
