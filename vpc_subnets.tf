# private subnet
# 3 private subnet
# range 192.168.0.0 - 192.168.3.255
resource "aws_subnet" "backend" {
  # max 3
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 0)
  map_public_ip_on_launch = true

  availability_zone_id = element(data.aws_availability_zones.available.zone_ids, count.index)

  tags = {
    Name = "${local.project_name}-backend-${element(data.aws_availability_zones.available.names, count.index)}-${count.index}"
    "kubernetes.io/role/internal-elb" = "1"
  }

  depends_on = [
    aws_internet_gateway.main_gw
  ]
}

# public subnet
# 3 public subnet
# range 192.168.4.0 - 192.168.7.255
resource "aws_subnet" "frontend" {
  # max 3
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 8, count.index + 3)
  map_public_ip_on_launch = true

  availability_zone_id = element(data.aws_availability_zones.available.zone_ids, count.index)

  tags = {
    Name = "${local.project_name}-frontend-${element(data.aws_availability_zones.available.names, count.index)}-${count.index}"
    "kubernetes.io/role/elb" = "1"
  }

  depends_on = [
    aws_internet_gateway.main_gw
  ]
}
