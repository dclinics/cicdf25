variable "users" {
  type = list(string)
  default = [
    "dclinics"
  ]
}


variable "passwd" {
  type    = string
  default = "$6$aoRSQZTRYZX385FJ$BHV7FWeeGQddTWJmHBkrPJuIlkoE8JuNE2dNf3mwpUNBH2oaKqyBLhu6tE8LUvjznV3UopxVqkSZ7fTALA0AW1"
}
