# private subnet
# 3 private subnet
# range 192.168.0.0 - 192.168.11.255
resource "aws_subnet" "backend" {
  # max 3
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 6, count.index + 0)
  map_public_ip_on_launch = true

  availability_zone_id = element(data.aws_availability_zones.available.zone_ids, count.index)

  tags = {
    Name = "backend-${element(data.aws_availability_zones.available.names, count.index)}-${count.index}"
  }
}

# public subnet
# 3 public subnet
# range 192.168.12.0 - 192.168.23.0
resource "aws_subnet" "public" {
  # max 3
  count = 3

  vpc_id                  = aws_vpc.main.id
  cidr_block              = cidrsubnet(aws_vpc.main.cidr_block, 6, count.index + 3)
  map_public_ip_on_launch = true

  availability_zone_id = element(data.aws_availability_zones.available.zone_ids, count.index)

  tags = {
    Name = "public-${element(data.aws_availability_zones.available.names, count.index)}-${count.index}"
  }
}
