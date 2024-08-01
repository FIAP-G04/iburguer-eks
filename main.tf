module "vpc" {
  source = "./modules/vpc"
  prefix = var.prefix
  vpc_cidr_block = var.vpc_cidr_block
  cluster_name = var.cluster_name
}

module "eks" {
  source = "./modules/eks"
  vpc_id = module.vpc.vpc_id
  prefix = var.prefix
  cluster_name = var.cluster_name
  retention_days = var.retention_days
  desired_size = var.desired_size
  max_size = var.max_size
  min_size = var.min_size
  subnet_ids = concat(module.vpc.private_subnet_ids, module.vpc.public_subnet_ids)
  cluster_config_path = var.cluster_config_path
}

module "sqs-cart-closed" {
  source = "./modules/sqs"
  name = var.prefix
  queue = "CartClosed"
}

module "sqs-payment-approved" {
  source = "./modules/sqs"
  name = var.prefix
  queue = "PaymentApproved"
}

module "sqs-payment-refused" {
  source = "./modules/sqs"
  name = var.prefix
  queue = "PaymentRefused"
}

module "sqs-order-generated" {
  source = "./modules/sqs"
  name = var.prefix
  queue = "OrderRegistered"
}