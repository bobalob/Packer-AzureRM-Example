#Terraform file to create the required resources for packer

resource "azurerm_resource_group" "packerDemo" {
  name     = "packerdemo"
  location = "North Europe"

  tags {
    usage = "packerDemo"
  }
}

resource "azurerm_storage_account" "packerStorages" {
    name = "packerstorages99"
    resource_group_name = "${azurerm_resource_group.packerDemo.name}"
    location = "North Europe"
    account_type = "Standard_LRS"

    tags {
        usage = "packerDemo"
    }
}

resource "azurerm_storage_container" "imagesContainer" {
    name = "images"
    resource_group_name = "${azurerm_resource_group.packerDemo.name}"
    storage_account_name = "${azurerm_storage_account.packerStorages.name}"
    container_access_type = "private"
}
