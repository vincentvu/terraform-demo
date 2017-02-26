variable "env" {}

resource "aws_iam_role" "wordpress_instance" {
  name = "${var.env}-wordpress-instance"
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

resource "aws_iam_policy" "wordpress_instance" {
  name = "${var.env}-wordpress-instance"
  path = "/"
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Sid": "${var.env}DescribeTags",
      "Effect": "Allow",
      "Action": [
        "ec2:DescribeTags"
      ],
      "Resource": [
        "*"
      ]
    },
    {
      "Sid": "${var.env}cwlogs",
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "logs:DescribeLogStreams"
      ],
      "Resource": [
        "arn:aws:logs:*:*:*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_policy_attachment" "wordpress_instance" {
  name = "${var.env}-wordpress-instance"
  roles = ["${aws_iam_role.wordpress_instance.name}"]
  policy_arn = "${aws_iam_policy.wordpress_instance.arn}"
}

resource "aws_iam_instance_profile" "wordpress_instance" {
  name = "${var.env}-wordpress-instance"
  roles = ["${aws_iam_role.wordpress_instance.name}"]
}

output "iam_role_wordpress_instance" {
  value = "${aws_iam_role.wordpress_instance.arn}"
  depends_on = ["aws_iam_policy_attachment.wordpress_instance"]
}

output "iam_profile_wordpress_instance" {
  value = "${aws_iam_instance_profile.wordpress_instance.name}"
  depends_on = ["aws_iam_policy_attachment.wordpress_instance"]
}
