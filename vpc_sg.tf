resource "aws_default_security_group" "default" {
  vpc_id = aws_vpc.main.id

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  tags = {
    Name = "default"
  }
}

resource "aws_security_group" "eks_cluster" {
  vpc_id      = aws_vpc.main.id
  description = "EKS Cluster Security Group"

  ingress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }

  egress {
    from_port = 0
    to_port   = 0
    protocol  = "-1"
    self      = true
  }
}

resource "aws_security_group" "internet" {
  vpc_id      = aws_vpc.main.id
  description = "Allow outbound internet traffic"

  egress {
    from_port = 0
    protocol  = -1
    to_port   = 0

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name = "internet"
  }
}

resource "aws_security_group" "ssh-inbound" {
  vpc_id      = aws_vpc.main.id
  description = "Allow inbound SSH traffic"

  ingress {
    from_port = 22
    to_port   = 22
    protocol  = "TCP"

    cidr_blocks = [
      "0.0.0.0/0"
    ]
  }

  tags = {
    Name = "ssh-inbound"
  }
}
