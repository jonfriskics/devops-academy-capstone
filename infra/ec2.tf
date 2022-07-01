# + Create a security group.
# + Allow egress from all sources on all ports
# + Allow ingress from all sources on port 443
# + Allow ingress within the private subnets on the VPC on the database port (default is 5432)
# + Allow ingress within the private subnets on the VPC on the backend api listener port (8080)
# + Allow ingress from all sources on port 22. (This is to allow GitHub Actions to deploy the application using ssh protocols. Normally we would limit the sources to CIDR ranges of private Self-Hosted GitHub runners.)

# + Create multiple EC2 instances that will host the todo-backend GraphQL API server. These will run behind a load balancer (found in alb.tf).
# + Use an LTS Ubuntu AMI for the servers (a data source for this has been provided in ec2.tf)
# + Create an IAM instance profile for the servers as well.

resource "aws_security_group" "backend_server" {
  #checkov:skip=CKV_AWS_24:Enable ssh access from all sources since we don't have access to private GH Actions runners
  vpc_id = aws_vpc.main.id

  ingress {
    to_port     = 22
    from_port   = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = 443
    from_port   = 443
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    to_port     = 5432
    from_port   = 5432
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  ingress {
    to_port     = 8080
    from_port   = 8080
    protocol    = "tcp"
    cidr_blocks = [aws_vpc.main.cidr_block]
  }

  egress {
    to_port     = 0
    from_port   = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

data "aws_ami" "ubuntu" {
  owners      = ["099720109477"] # canonical
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }
}

resource "aws_instance" "backend_server" {
  #checkov:skip=CKV_AWS_88:Allow public IP for ssh access deploy since we don't have access to private GH Actions runners
  depends_on = [aws_route_table.main]

  count                  = length(aws_subnet.main)
  ami                    = data.aws_ami.ubuntu.id
  iam_instance_profile   = aws_iam_instance_profile.backend_server.name
  subnet_id              = aws_subnet.main.*.id[count.index]
  vpc_security_group_ids = [aws_security_group.backend_server.id]

  tags = var.aws_tags
}
