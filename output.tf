output "vpc_id" {
  value = "${aws_vpc.ceros_vpc.id}"
}
output "public_subnets" {
  value = ["${aws_subnet.subnet_public.id}"]
}
output "public_route_table_ids" {
  value = ["${aws_route_table.ceros_rtb_public.id}"]
}
output "public_instance_ip" {
  value = ["${aws_instance.ceros_app.public_ip}"]
}