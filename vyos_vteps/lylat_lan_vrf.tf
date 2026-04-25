resource "vyos_vrf_name" "lylat_lan" {
  identifier = { name = "lylat_lan" }
  table = 1337
}
