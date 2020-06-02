resource("random_pet", "this",
  length: 1, # using 1, since default separator is '-', also account name can only be 24 characters, and lowercase letters
)

resource("azurerm_resource_group", "this",
  name:     "demo-resources-${random_pet.this.id}",
  location: "eastus",
)

module!("storage_account",
  source:              "../../modules/example",
  name:                "sa${random_pet.this.id}",
  resource_group_name: "${azurerm_resource_group.this.name}",
  location:            "${azurerm_resource_group.this.location}",
)
