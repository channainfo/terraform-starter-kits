
data "aws_availability_zones" "available" {
  state = "available"
}

resource "aws_vpc" "main" {
  cidr_block       = var.vpc_cidr
  instance_tenancy = "default"

  tags = merge(var.default_tags, {
    Name     = var.name
    Location = var.region
  })
}

resource "aws_subnet" "publics" {
  count = length(local.az_names)

  # availability_zone = data.aws_availability_zones.az_names.names[count.index]
  availability_zone = local.az_names[count.index]

  vpc_id     = aws_vpc.main.id
  cidr_block = replace(var.subnet_cidr_format, "x", "${1 + count.index}")

  tags = {
    Name = "${var.name} Public Subnet ${count.index+1}"
  }
}

resource "aws_subnet" "privates" {
  count = length(local.az_names)

  availability_zone = local.az_names[count.index]

  vpc_id     = aws_vpc.main.id
  cidr_block = replace(var.subnet_cidr_format, "x", "${101 + count.index}")

  tags = {
    Name = "${var.name} Private Subnet ${count.index+1}"
  }
}

######################### Create an internet gateways and attach it to public subnets to allow host in public subnets to communitcate with internet
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "Internet Gateway for public Subnet"
  }
}

resource "aws_route_table" "ig" {
  vpc_id = aws_vpc.main.id

  # route to internet gateway
  route {
    cidr_block = "0.0.0.0/0"

    # both nat_gateway_id and gateway_id is very forgiving by aws.
    # to avoid constant statediff use it correctly by gateway_id
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.name} Route table IG"
  }
}

resource "aws_route_table_association" "rta_public" {
  count          = length(aws_subnet.publics)
  subnet_id      = aws_subnet.publics[count.index].id
  route_table_id = aws_route_table.ig.id
}

######################### End Attach internet gateway to public subnets



######################### Create public ip for NAT gateway to allows host in private to use public subnets as their gateway to access the internet
resource "aws_eip" "main" {
  tags = {
    Name = "PublicIp for ${var.name} NAT"
  }
}

resource "aws_nat_gateway" "main" {

  allocation_id = aws_eip.main.id
  # Create only one nat gateway in the first public subnet
  subnet_id = aws_subnet.publics[0].id

  tags = {
    Name = "${var.name} NAT Gateway"
  }
}

resource "aws_route_table" "nat" {
  vpc_id = aws_vpc.main.id

  # route to internet gateway
  route {
    cidr_block = "0.0.0.0/0"
    # both nat_gateway_id and gateway_id is very forgiving by aws.
    # to avoid constant statediff use it correctly by nat_gateway_id
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.name} NAT Route table"
  }
}

resource "aws_route_table_association" "rta_main_private" {
  count          = length(aws_subnet.privates)
  subnet_id      = aws_subnet.privates[count.index].id
  route_table_id = aws_route_table.nat.id
}

######################### End Nat Gateway
