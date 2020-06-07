data template_file "user_data" {
  template = file("${path.module}/user_data_control_plane.sh.tpl")

  vars = {
    auto_scaling_group_name = var.auto_scaling_group_name
    lifecycle_hook_name     = var.lifecycle_hook_name
  }
}
