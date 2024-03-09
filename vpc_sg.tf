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
    Name = "${local.project_name}-default"
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
    Name = "${local.project_name}-internet"
  }
}

resource "aws_security_group" "public_nlb" {
  vpc_id      = aws_vpc.main.id
  description = "Allow inbound traffic to public NLB"

  ingress {
    protocol  = "TCP"
    from_port = 80
    to_port   = 80

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  ingress {
    protocol  = "TCP"
    from_port = 443
    to_port   = 443

    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  egress {
    from_port = 0
    protocol  = -1
    to_port   = 0

    cidr_blocks      = [aws_vpc.main.cidr_block]
  }

  tags = {
    Name = "${local.project_name}-public-nlb"
  }
}

resource "aws_security_group" "public_nlb_target" {
  vpc_id      = aws_vpc.main.id
  description = "Allow inbound traffic from public NLB to targets"

  ingress {
    protocol = "TCP"
    from_port = 30080
    to_port   = 30080

    security_groups = [aws_security_group.public_nlb.id]
  }
  ingress {
    protocol = "TCP"
    from_port = 30443
    to_port   = 30443

    security_groups = [aws_security_group.public_nlb.id]
  }
  ingress {
    protocol = "TCP"
    from_port = 30843
    to_port   = 30843

    security_groups = [aws_security_group.public_nlb.id]
  }

  tags = {
    Name = "${local.project_name}-public-nlb-target"
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
    Name = "${local.project_name}-ssh-inbound"
  }
}
