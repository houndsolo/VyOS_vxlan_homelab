variable "dns_servers" {
  description = "DNS configuration"
  type = list(string)
  default = ["10.8.6.9"]
}

variable "spines" {
  type = number
  default = 2
}

variable "leaves" {
  description = "List of regular VTEP leaf nodes."
  type = list(object({
    hostname  = string
    host_node = string
    node_id   = number
  }))
}

variable "border_leaves" {
  description = "List of border VTEP leaf nodes."
  type = list(object({
    hostname  = string
    host_node = string
    node_id   = number
  }))
}

variable "gf_leafs" {
  description = "List of Great Fox leaf nodes."
  type = list(object({
    hostname  = string
    host_node = string
    node_id   = number
  }))
}
