# ===========================
# Generic Variables
# ===========================
variable "alias" {
  description = "Short alias identifier for naming resources (e.g., 'Papaya', 'Mango')"
  type        = string
}

variable "asset_owner_name" {
  description = "Name of the asset owner for tagging resources"
  type        = string
}