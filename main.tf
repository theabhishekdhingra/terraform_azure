# my first terraform main.tf

terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.37.0"
    }
  }
}

provider "azurerm" {
  # Configuration options
  tenant_id= "881b6799-c60b-4fe5-9a1648e9"
  features {
  }
}

resource "azurerm_resource_group" "main" {
  name     = "rg_terraform"
  location = "Central India"

  tags = {
    "Env" = "Terraform_automate"
  }
}

resource "azurerm_virtual_network" "main" {
  name                = "vn_under_rg_terraform"
  resource_group_name = azurerm_resource_group.main.name
  address_space       = [ "10.1.0.0/16" ]
  location            = azurerm_resource_group.main.location

  tags = {
    "Env" = "Terraform_automate"
  }
}

resource "azurerm_subnet" "main" {
  name                 = "subnet_vn_under_rg_terraform"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.1.1.0/24"]
}

resource "azurerm_network_interface" "internal" {
  name                 = "internal-nic"
  location             = azurerm_resource_group.main.location
  resource_group_name  = azurerm_resource_group.main.name
  
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.main.id
    private_ip_address_allocation = "Static"
    private_ip_address            = "10.1.1.5"
    }

}


resource "azurerm_linux_virtual_machine" "new_vm" {
  name                        = "terraform-in"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  network_interface_ids = [azurerm_network_interface.internal.id]
  size = "Standard_B1s"
  disable_password_authentication = false
  admin_username = "abhishek"
  admin_password = ""

  os_disk {
    caching = "None"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer = "UbuntuServer"
    sku = "18.04-LTS"
    version = "latest"
  }
  
}
