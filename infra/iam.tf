resource "aws_iam_instance_profile" "backend_server" {
  name = "${var.project_name}-profile"
  role = aws_iam_role.project.name
}

resource "aws_iam_role" "project" {
  name               = "${var.project_name}-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json

}

data "aws_iam_policy_document" "assume_role" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = [
        "ec2.amazonaws.com",
      ]
    }
  }
}