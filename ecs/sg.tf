## Security Groups

resource "aws_security_group" "cadence_task_sg" {
  name   = "Cadence SG"
  vpc_id = local.vpc_id
}

resource "aws_security_group" "cassandra_sg" {
  name   = "Cassandra SG"
  vpc_id = local.vpc_id
}


## Security Group Rules

resource "aws_security_group_rule" "cadence_task_allow_outbound" {
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  cidr_blocks       = ["0.0.0.0/0"]
  ipv6_cidr_blocks  = ["::/0"]
  security_group_id = aws_security_group.cadence_task_sg.id
}

resource "aws_security_group_rule" "allow_cadence_to_cassandra" {
  type                     = "ingress"
  from_port                = 9142
  to_port                  = 9142
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cassandra_sg.id
  source_security_group_id = aws_security_group.cadence_task_sg.id
}


## VPC Endpoints

resource "aws_vpc_endpoint" "cassandra_endpoint" {
  vpc_id            = local.vpc_id
  service_name      = "com.amazonaws.ap-southeast-1.cassandra"
  vpc_endpoint_type = "Interface"

  security_group_ids = [
    aws_security_group.cassandra_sg.id,
  ]

  private_dns_enabled = true
}

resource "aws_vpc_endpoint_security_group_association" "sg_ec2" {
  vpc_endpoint_id   = aws_vpc_endpoint.cassandra_endpoint.id
  security_group_id = aws_security_group.cassandra_sg.id
}