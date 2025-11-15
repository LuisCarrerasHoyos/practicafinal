## Directorio Terraform
Crea infraestructura en AWS:

- VPC personalizada con rango CIDR configurable
- Dos subredes públicas en diferentes Zonas de Disponibilidad
- Instancias EC2:
  - Servidor web - tag: role = "web"
  - Servidor de base de datos - tag: role = "db"
- Grupos de Seguridad:
  - Servidores web: HTTP (80), HTTPS (443), SSH (22) desde cualquier lugar
  - Base de datos: Puerto 3306 solo desde servidores web

## Directorio Ansible
Configura servidores automáticamente:

- Inventario dinámico desde AWS EC2
- Dos roles:
  - Rol webserver: Instala Apache, PHP, WordPress, configura wp-config.php
  - Rol database: Instala base de datos, crea DB y usuario para WordPress
- Validación: `ansible-inventory --graph`

## deploy.sh
Script automatizado que ejecuta:
1. Terraform para crear la infraestructura
2. Ansible para configurar los servidores
