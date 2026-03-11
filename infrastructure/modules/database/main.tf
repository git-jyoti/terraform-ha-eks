resource "aws_rds_global_cluster" "this" {
  count                     = var.is_global_cluster ? 1 : 0
  global_cluster_identifier = "${var.project_name}-global-db"
  engine                    = "aurora-postgresql"
  engine_version            = var.engine_version
  database_name             = var.db_name
}

resource "aws_rds_cluster" "this" {
  cluster_identifier        = "${var.project_name}-cluster"
  engine                    = "aurora-postgresql"
  engine_version            = var.engine_version
  global_cluster_identifier = var.global_cluster_id
  master_username           = var.master_username
  master_password           = var.master_password
  db_subnet_group_name      = var.db_subnet_group_name
  vpc_security_group_ids    = var.vpc_security_group_ids
  skip_final_snapshot       = true

  tags = var.tags
}

resource "aws_rds_cluster_instance" "this" {
  count              = var.instance_count
  identifier         = "${var.project_name}-instance-${count.index}"
  cluster_identifier = aws_rds_cluster.this.id
  instance_class     = var.instance_class
  engine             = aws_rds_cluster.this.engine
  engine_version     = aws_rds_cluster.this.engine_version
}
