# =====================================================================
# CyberArk Identity User Creation
# =====================================================================
resource "idsec_identity_user" "users" {
  for_each = { for user in var.users : join(".", [user.first_name, user.last_name]) => user }

  username          = "${each.value.first_name}.${each.value.last_name}"
  display_name      = "${each.value.first_name} ${each.value.last_name}"
  suffix            = var.domain_name
  email             = each.value.email
  mobile_number     = each.value.mobile_number
  in_everybody_role = true
  send_email_invite = false
  send_sms_invite   = false

  lifecycle {
    ignore_changes = [
      send_email_invite,
      send_sms_invite,
      force_password_change_next,
      suffix,
      user_id,
      last_login,
      mobile_number
    ]
  }
}

