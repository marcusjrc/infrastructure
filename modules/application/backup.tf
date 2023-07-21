resource "aws_backup_vault" "database_backups" {
  name        = "rds_backup_vault"
}

resource "aws_backup_plan" "rds_backup" {
  name = "backup-rds"

  rule {
    rule_name         = "backup_rds"
    target_vault_name = aws_backup_vault.database_backups.name
    schedule          = "cron(0 12 * * ? *)"
    enable_continuous_backup = true
    lifecycle {
      delete_after = 30
    }
  }
}

resource "aws_iam_role" "rds_backup_role" {
  name               = "rds_backup_role"
  assume_role_policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": ["sts:AssumeRole"],
      "Effect": "allow",
      "Principal": {
        "Service": ["backup.amazonaws.com"]
      }
    }
  ]
}
POLICY
}

resource "aws_iam_role_policy_attachment" "rds_backup_role_policy_attachment" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSBackupServiceRolePolicyForBackup"
  role       = "${aws_iam_role.rds_backup_role.name}"
}

resource "aws_backup_selection" "backup-selection" {
  iam_role_arn = aws_iam_role.rds_backup_role.arn
  name         = "backup_rds_selection"
  plan_id      = aws_backup_plan.rds_backup.id
  selection_tag {
    type  = "STRINGEQUALS"
    key   = "Backup"
    value = true
  }
}