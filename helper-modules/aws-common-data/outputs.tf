output "aws_availability_zones" {
  description = "AWS Availibility Zones"
  value = data.aws_availability_zones.available
}
