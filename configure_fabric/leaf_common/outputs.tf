output "ready" {
  description = "Dependency anchor for role-specific VRF resources that must wait for shared base fabric resources."
  value       = true
  depends_on  = [vyos_protocols_bgp_address_family_l2vpn_evpn.l2vpn_evpn_config]
}
