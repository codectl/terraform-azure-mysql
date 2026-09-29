module "naming" {
  source  = "codectl/naming/azure"
  version = "~> 0.1"

  suffix = ["demo", "dev"]
}

module "regions" {
  source  = "codectl/locations/azure"
  version = "~> 1.0"

  location = {
    primary = "swedencentral"
  }
}

module "rg" {
  source  = "codectl/rg/azure"
  version = "~> 1.0"

  groups = {
    demo = {
      name     = module.naming.resource_group.name_unique
      location = module.regions.location.primary.name
    }
  }
}

module "kv" {
  source  = "codectl/kv/azure"
  version = "~> 1.0"


  vault = {
    name                = module.naming.key_vault.name_unique
    location            = module.rg.groups.demo.location
    resource_group_name = module.rg.groups.demo.name

    secrets = {
      random_string = {
        db = {
          length  = 24
          special = true
        }
      }
    }
  }
}

module "mysql" {
  source  = "codectl/mysql/azure"
  version = "~> 1.0"

  mysql_flexible_server = {
    name                   = module.naming.mysql_server.name_unique
    location               = module.rg.groups.demo.location
    resource_group_name    = module.rg.groups.demo.name
    administrator_password = module.kv.secrets.db.value
    administrator_login    = "adminLogin"
    sku_name               = "GP_Standard_D8ds_v4"
    version                = "8.0.21"
    zone                   = "1"

    high_availability = {
      mode                      = "ZoneRedundant"
      standby_availability_zone = "2"
    }
  }
}
