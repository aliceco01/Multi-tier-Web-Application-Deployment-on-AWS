# Create a security group for the front-end instances
resource "aws_security_group" "front_end_sg" {
  name        = "front-end-security-group"
  description = "Security group for front-end instances"

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# Create an Auto Scaling Group for the front-end instances
resource "aws_autoscaling_group" "front_end_asg" {
  name                 = "front-end-asg"
  launch_configuration = aws_launch_configuration.front_end_lc.name
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.public_subnet.id]
  health_check_type    = "ELB"
  tags = [
    {
      key                 = "Name"
      value               = "front-end-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "production"
      propagate_at_launch = true
    },
  ]
}

# Create a Launch Configuration for the front-end instances
resource "aws_launch_configuration" "front_end_lc" {
  name                        = "front-end-launch-config"
  image_id                    = "ami-xxxxxxxxxxxxxxxxx"
  instance_type               = "t2.micro"
  key_name                    = "your-key-pair-name"
  security_groups             = [aws_security_group.front_end_sg.id]
  associate_public_ip_address = true
  user_data                   = filebase64("front_end_user_data.sh")
}

# Create an Elastic Load Balancer (ELB) for the front-end instances
resource "aws_elb" "front_end_elb" {
  name               = "front-end-elb"
  subnets            = [aws_subnet.public_subnet.id]
  security_groups    = [aws_security_group.front_end_sg.id]
  instances          = aws_autoscaling_group.front_end_asg.id
  health_check {
    target              = "HTTP:80/"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }
  tags = {
    Name = "front-end-elb"
  }
}

# Output the ELB DNS name for accessing the front-end application
output "front_end_elb_dns" {
  value = aws_elb.front_end_elb.dns_name
}
