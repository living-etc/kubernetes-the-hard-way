resource aws_iam_role "role" {
  name = var.role_name

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

resource aws_iam_instance_profile "kubernetes_control_plane" {
  name = var.role_name
  role = aws_iam_role.role.name
}

resource aws_iam_role_policy_attachment "systems_manager" {
  role       = aws_iam_role.role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource aws_iam_role_policy_attachment "complete_lifecycle_action" {
  role       = aws_iam_role.role.name
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
      var.auto_scaling_group_name
    ]
  }
}
