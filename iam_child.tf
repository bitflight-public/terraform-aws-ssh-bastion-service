#role in child account

resource "aws_iam_role" "bastion_service_assume_role" {
  name = "${module.label.id}-role"

  count = "${local.assume_role_yes}"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow"
    }
  ]
}
EOF
}

#Instance profile
resource "aws_iam_instance_profile" "bastion_service_assume_role_profile" {
  name  = "${module.label.id}-profile"
  count = "${local.assume_role_yes}"
  role  = "${aws_iam_role.bastion_service_assume_role.name}"
}

data "aws_iam_policy_document" "bastion_service_assume_role_in_parent" {
  count = "${local.assume_role_yes}"

  statement {
    effect = "Allow"

    actions = [
      "sts:AssumeRole",
    ]

    resources = [
      "${var.assume_role_arn}",
    ]
  }
}

resource "aws_iam_policy" "bastion_service_assume_role_in_parent" {
  count  = "${local.assume_role_yes}"
  name   = "${module.label.id}-policy"
  policy = "${data.aws_iam_policy_document.bastion_service_assume_role_in_parent.json}"
}

resource "aws_iam_role_policy_attachment" "bastion_service_assume_role" {
  role       = "${aws_iam_role.bastion_service_assume_role.name}"
  count      = "${local.assume_role_yes}"
  policy_arn = "${aws_iam_policy.bastion_service_assume_role_in_parent.arn}"
}
