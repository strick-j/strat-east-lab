# ===========================
# CMGR Pool and Network Outputs
# ===========================
output "cmgr_pool_id" {
  description = "The ID of the CMGR pool"
  value       = idsec_cmgr_pool.cmgr_pool.pool_id
}

output "cmgr_network_id" {
  description = "The ID of the CMGR network"
  value       = idsec_cmgr_network.cmgr_network.network_id
}