resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# MARK - when I uncomment these, it writes the key files to the local directory.  I would do that if I want to add those keys to my local machine to connect, correct?
resource "local_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "./ssh_key"
  file_permission = "0600"
}

resource "local_file" "public_key" {
  content         = tls_private_key.ssh.public_key_openssh
  filename        = "./ssh_key.pub"
  file_permission = "0644"
}

resource "aws_key_pair" "ssh_key" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}
