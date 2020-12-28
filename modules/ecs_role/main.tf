# ecs_task_assume_role allow ecs-tasks.amazonaws.com to act on our behalf
resource "aws_iam_role" "ecs_task_assume_role" {
  name               = "${var.name}-task"
  assume_role_policy = file("${path.module}/template/task_role.json")
  # file("./policies/ecs_task_assume_role.json")
}

# gives ecs_task_assume_role with the following permission
resource "aws_iam_role_policy" "ecs_task_assume_policy" {
  name   = "ecs_task_assume_policy"
  role   = aws_iam_role.ecs_task_assume_role.id
  policy = file("${path.module}/template/task_policy.json")
}


# ecs_task_exec_role allows ecs-tasks.amazonaws.com to act on our behalf
resource "aws_iam_role" "ecs_task_exec_role" {
  name_prefix        = "${var.name}-task-exec"
  assume_role_policy = file("${path.module}/template/exec_role.json")
}

# give ecs_task_exec_role with aws built-in  managed policy for exec.
# https://console.aws.amazon.com/iam/home?region=eu-west-1#/policies/arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy$jsonEditor
resource "aws_iam_role_policy_attachment" "ecs_task_exec_policy" {
  role       = aws_iam_role.ecs_task_exec_role.id
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}


# ECS EC2 requires instance profile to interact with ECS, in constrast with Fargate which is automatically managed.
# ecs_task_assume_role allow services( ecs-tasks.amazonaws.com and ec2.amazonaws.com ) to act on our behalf
resource "aws_iam_role" "ecs_instance_role" {
  name_prefix           = "${var.name}-ec2"
  force_detach_policies = true # This role can be deleted or recreated
  assume_role_policy    = file("${path.module}/template/ec2_role.json")
}

# gives ecs_task_assume_role with the following permission
resource "aws_iam_role_policy" "ecs_instance_policy" {
  name   = "ecs_task_assume_policy"
  role   = aws_iam_role.ecs_instance_role.id
  policy = file("${path.module}/template/ec2_instanace_policy.json")
}

# ec2 instance will perform the role above
resource "aws_iam_instance_profile" "main" {
  name_prefix = var.name
  role        = aws_iam_role.ecs_instance_role.id
}
