# Create a security group for the application instances
resource "aws_security_group" "application_sg" {
  name        = "application-security-group"
  description = "Security group for application instances"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Add any additional ingress rules as needed for your application
}

# Create an Auto Scaling Group for the application instances
resource "aws_autoscaling_group" "application_asg" {
  name                 = "application-asg"
  launch_configuration = aws_launch_configuration.application_lc.name
  min_size             = 2
  max_size             = 5
  desired_capacity     = 2
  vpc_zone_identifier  = [aws_subnet.private_subnet.id]
  health_check_type    = "EC2"
  tags = [
    {
      key                 = "Name"
      value               = "application-instance"
      propagate_at_launch = true
    },
    {
      key                 = "Environment"
      value               = "production"
      propagate_at_launch = true
    },
  ]
}

# Create a Launch Configuration for the application instances
resource "aws_launch_configuration" "application_lc" {
  name                        = "application-launch-config"
  image_id                    = "ami-xxxxxxxxxxxxxxxxx"
  instance_type               = "t2.micro"
  key_name                    = "your-key-pair-name"
  security_groups             = [aws_security_group.application_sg.id]
  associate_public_ip_address = false
  user_data                   = filebase64("application_user_data.sh")
}

# Output the Auto Scaling Group name and Launch Configuration name for reference
output "application_asg_name" {
  value = aws_autoscaling_group.application_asg.name
}

output "application_lc_name" {
  value = aws_launch_configuration.application_lc.name
}
