variable rg_name {}
variable rg_location {}
variable environment {}
variable cidr_block {}
variable subnet_bits {
  type = number
  default = 3
}
variable domain_name {}
variable base_net {
  type    = number
  default = 0
}
variable subarea {}