# Obtener las zonas de disponibilidad disponibles
data "aws_availability_zones" "available" {}

# Crear la VPC
resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "wordpress-vpc-luis"
  }
}

# Crear el Internet Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "wordpress-igw"
  }
}

# Crear las dos subredes públicas (en distintas zonas)
resource "aws_subnet" "public" {
  for_each = {
    az1 = var.public_subnet_cidrs[0]
    az2 = var.public_subnet_cidrs[1]
  }

  vpc_id                  = aws_vpc.main.id
  cidr_block              = each.value
  availability_zone       = data.aws_availability_zones.available.names[ (each.key == "az1" ? 0 : 1) ]
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet-${each.key}"
  }
}
# Crear tabla de rutas para las subredes públicas
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name = "public-rt"
  }
}

# Asociar tabla de rutas a las subredes públicas
resource "aws_route_table_association" "public_assoc" {
  for_each = aws_subnet.public
  subnet_id      = each.value.id
  route_table_id = aws_route_table.public.id
}

# Crear grupos de seguridad

# Grupo de seguridad para el servidor web
resource "aws_security_group" "web_sg" {
  name        = "web-sg"
  description = "Allow HTTP, HTTPS, SSH"
  vpc_id      = aws_vpc.main.id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "web-sg"
  }
}

# Grupo de seguridad para el servidor de base de datos
resource "aws_security_group" "db_sg" {
  name        = "db-sg"
  description = "Allow MySQL from web server"
  vpc_id      = aws_vpc.main.id

  ingress {
    description     = "MySQL from web server"
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.web_sg.id]
  }

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "db-sg"
  }
}

# Crear clave SSH
#resource "aws_key_pair" "main" {
#  key_name   = "terraform-key"
#  public_key = var.public_key
#}

resource "aws_key_pair" "main" {
  key_name   = "terraform-key"
  public_key = file("./.ssh/terraform_key.pub")
}

# Buscar AMI de Ubuntu
data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

# Instancia Web
resource "aws_instance" "web" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_web
  subnet_id = element([for s in aws_subnet.public : s.id], 0)
  #key_name               = aws_key_pair.main.key_name
  key_name                = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.web_sg.id]

  tags = {
  Name = "webserver"
  Role = "web"
   }
}

# Instancia DB
resource "aws_instance" "db" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type_db
  subnet_id = element([for s in aws_subnet.public : s.id], 0)
  #key_name               = aws_key_pair.main.key_name
  key_name                = aws_key_pair.main.key_name
  vpc_security_group_ids = [aws_security_group.db_sg.id]

  tags = {
  Name = "dbserver"
  Role = "db"
   }
}
