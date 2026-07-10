output "ready" {
  description = "Dependency anchor for role-specific access resources that must wait for shared VXLAN and bridge resources."
  value       = true
  depends_on  = [vyos_interfaces_bridge.vxlan_bridge_L2]
}
