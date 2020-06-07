data template_cloudinit_config "config" {
  gzip          = true
  base64_encode = true

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.user_data.rendered
    filename     = "user-data.sh"
  }
}
