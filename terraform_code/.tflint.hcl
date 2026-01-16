plugin "terraform" {
  enabled = true
  preset  = "recommended"
}

plugin "aws" {
    enabled = true
    version = "0.45.0"
    source  = "github.com/terraform-linters/tflint-ruleset-aws"
}

# Enforces naming conventions
rule "terraform_naming_convention" {
enabled = true
  #Require specific naming structure
  variable {
  format = "snake_case"
  }
  
  locals {
  format = "snake_case"
  }
  
  output {
  format = "snake_case"
  }
  
  #Allow any format
  resource {
  format = "none"
  }
  
  module {
  format = "none"
  }
  
  data {
  format = "none"
  }
}