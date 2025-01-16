#!/bin/bash

# Comprobamos si el script se ejecuta como root
if [ "$EUID" -ne 0 ]; then
  echo "Por favor, ejecuta este script como root."
  exit
fi

echo "Actualizando los paquetes del sistema..."
apt update && apt upgrade -y

echo "Instalando Apache..."
apt install apache2 -y
systemctl start apache2
systemctl enable apache2

echo "Instalando MySQL..."
apt install mysql-server -y
systemctl start mysql
systemctl enable mysql

echo "Configurando MySQL..."
mysql_secure_installation

echo "Instalando PHP..."
apt install php libapache2-mod-php php-mysql -y

echo "Instalando phpMyAdmin..."
DEBIAN_FRONTEND=noninteractive apt install phpmyadmin -y

echo "Configurando phpMyAdmin..."
ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

echo "Reiniciando Apache para aplicar los cambios..."
systemctl restart apache2

echo "Creando usuario MySQL genérico..."
mysql -u root -e "CREATE USER 'admin'@'%' IDENTIFIED BY '1234';"
mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION;"
mysql -u root -e "FLUSH PRIVILEGES;"

echo "Usuario MySQL 'admin' creado con contraseña '1234'."

echo "Configurando permisos de firewall (si es necesario)..."
ufw allow in "Apache Full"

echo "LAMP stack instalado con éxito. Detalles:"
echo "----------------------------------------"
echo "Apache: http://localhost"
echo "phpMyAdmin: http://localhost/phpmyadmin"
echo "MySQL: Ejecute 'mysql -u admin -p' para acceder (contraseña: 1234)."
echo "----------------------------------------"
echo "¡Instalación completada!"
