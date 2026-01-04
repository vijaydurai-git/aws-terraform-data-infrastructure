resource "aws_security_group" "sg" {

  name   = "${var.project_tag_in}-${var.sg_tag}"
  vpc_id = var.vpc_id_in
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }


  lifecycle {
    ignore_changes = all

  }

  tags = {

    Name = "${var.project_tag_in}-${var.sg_tag}"
  }
}


# Ingress Rules
resource "aws_security_group_rule" "sg_ingress" {
  for_each = { for port in var.allowed_ports_in : port => port }

  type              = "ingress"
  from_port         = each.value
  to_port           = each.value
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.sg.id
}