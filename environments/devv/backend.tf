terraform {
  cloud {
    organization = "teleios"
    workspaces {
      tags = ["e-commerce"]
    }
  }
}
