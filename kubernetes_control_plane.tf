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

  initial_lifecycle_hook {
    name                 = "wait-for-provisioning-to-complete"
    default_result       = "CONTINUE"
    heartbeat_timeout    = 100
    lifecycle_transition = "autoscaling:EC2_INSTANCE_LAUNCHING"
  }
}

resource aws_launch_template "control_plane" {
  name          = "kubernetes-control-plane"
  image_id      = "ami-0ed613086d754c853"
  instance_type = "t2.small"
  user_data     = base64encode(data.template_file.user_data_control_plane.rendered)

  iam_instance_profile {
    name = aws_iam_instance_profile.kubernetes_control_plane.name
  }
}

data template_file "user_data_control_plane" {
  template = file("${path.module}/user_data_control_plane.sh.tpl")

  vars = {
    autoscaling_group_name = "kubernetes-control-plane"
    lifecycle_hook_name    = "wait-for-provisioning-to-complete"
  }
}

resource aws_iam_instance_profile "kubernetes_control_plane" {
  name = "kubernetes-control-plane"
  role = aws_iam_role.kubernetes_control_plane.name
}

resource aws_iam_role "kubernetes_control_plane" {
  name = "kubernetes-control-plane"

    assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": "sts:AssumeRole",
            "Principal": {
               "Service": "ec2.amazonaws.com"
            },
            "Effect": "Allow",
            "Sid": ""
        }
    ]
}
EOF
}

resource aws_iam_role_policy_attachment "systems_manager" {
  role       = aws_iam_role.kubernetes_control_plane.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource aws_iam_role_policy_attachment "control_plane_complete_lifecycle_action" {
  role       = aws_iam_role.kubernetes_control_plane.name
  policy_arn = aws_iam_policy.complete_lifecycle_action.arn
}

resource aws_iam_policy "complete_lifecycle_action" {
  name   = "complete_lifecycle_action"
  policy = data.aws_iam_policy_document.complete_lifecycle_action.json
}

data aws_iam_policy_document "complete_lifecycle_action" {
  statement {
    actions = [
      "autoscaling:CompleteLifecycleAction"
    ]

    resources = [
      aws_autoscaling_group.control_plane.arn
    ]
  }
}
