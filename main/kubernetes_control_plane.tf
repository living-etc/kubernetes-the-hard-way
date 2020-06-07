resource aws_autoscaling_group "control_plane" {
  name                      = "kubernetes-control-plane"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  health_check_grace_period = 300
  health_check_type         = "EC2"
  force_delete              = true
  vpc_zone_identifier       = module.vpc.private_subnets

  launch_template {
    id      = aws_launch_template.control_plane.id
    version = "$Latest"
  }
}

resource "aws_autoscaling_lifecycle_hook" "wait_for_provisioning_to_complete" {
  name                   = "wait-for-provisioning-to-complete"
  autoscaling_group_name = aws_autoscaling_group.control_plane.name
  default_result         = "CONTINUE"
  heartbeat_timeout      = 1000
  lifecycle_transition   = "autoscaling:EC2_INSTANCE_LAUNCHING"
}

resource aws_launch_template "control_plane" {
  name          = "kubernetes-control-plane"
  image_id      = "ami-0ed613086d754c853"
  instance_type = "t2.small"
  user_data     = module.user_data.rendered

  iam_instance_profile {
    name = local.control_plane_role_name
  }
}

module "user_data" {
  source                  = "../modules/cloud_config"
  auto_scaling_group_name = "kubernetes-control-plane"
  lifecycle_hook_name     = "wait-for-provisioning-to-complete"
}

module "iam_role" {
  source                  = "../modules/iam_role"
  auto_scaling_group_name = aws_autoscaling_group.control_plane.arn
  role_name               = local.control_plane_role_name
}
