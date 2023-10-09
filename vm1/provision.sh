#!/bin/bash

# 1. Atualizar o sistema
sudo apt-get update
sudo apt-get upgrade -y

# 2. Configurar o firewall UFW
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw enable

# 3. Configurar o Apache (servidor web)
sudo apt-get install apache2 -y
sudo systemctl enable apache2
sudo systemctl start apache2

# 4. Desabilitar informações de servidor Apache
sudo sed -i 's/ServerTokens OS/ServerTokens Prod/' /etc/apache2/conf-available/security.conf
sudo sed -i 's/ServerSignature On/ServerSignature Off/' /etc/apache2/conf-available/security.conf
sudo systemctl restart apache2

# 5. Configurar o mod_security (WAF)
sudo apt-get install libapache2-mod-security2 -y
sudo cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf
sudo systemctl restart apache2

# 6. Instalar e configurar o Fail2ban
sudo apt-get install fail2ban -y
sudo systemctl enable fail2ban
sudo systemctl start fail2ban

# 7. Configurar logrotate para registros de acesso do Apache
sudo apt-get install logrotate -y
sudo cp /etc/logrotate.d/apache2 /etc/logrotate.d/apache2.backup
sudo sed -i 's/weekly/daily/' /etc/logrotate.d/apache2
sudo sed -i 's/rotate 52/rotate 90/' /etc/logrotate.d/apache2

# 8. Implementar HTTPS (SSL/TLS)
sudo apt-get install certbot python3-certbot-apache -y
sudo certbot --apache

# 9. Configurar diretivas de segurança no Apache (mod_security)
sudo git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /etc/modsecurity/owasp-crs
cd /etc/modsecurity/
sudo cp /etc/modsecurity/owasp-crs/crs-setup.conf.example /etc/modsecurity/owasp-crs/crs-setup.conf
sudo sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/owasp-crs/crs-setup.conf
sudo a2enmod security2
sudo systemctl restart apache2

# 10. Monitorar e analisar registros de acesso do Apache com o ModSecurity Audit Log
sudo mkdir /var/log/modsec
sudo chown www-data:www-data /var/log/modsec
sudo chmod 755 /var/log/modsec

# Reiniciar o Apache para aplicar todas as configurações
sudo systemctl restart apache2