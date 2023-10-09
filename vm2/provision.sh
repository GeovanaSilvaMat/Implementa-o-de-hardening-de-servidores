#atualizar servicos
sudo apt-get update
sudo apt-get upgrade
sudo apt-get install -y mysql-server
sudo apt-get install isc-dhcp-server

#firewall
sudo apt-get install ufw -y
sudo ufw enable

#ssh->firewall
sudo ufw allow OpenSSH

#tripwire
sudo apt-get install tripwire -y
sudo tripwire --ivagcddnit
sudo tripwire --check

#fail2ban para o ssh
sudo apt-get install fail2ban -y

#Configure o MySQL para só ouvir em localhost
echo "bind-address = 127.0.0.1" | sudo tee -a /etc/mysql/mysql.conf.d/mysqld.cnf

#Atualizar as permissões de arquivos sensíveis
sudo chmod 600 /etc/mysql/mysql.conf.d/mysqld.cnf

#Mantenha o MySQL atualizado
sudo apt-get install unattended-upgrades -y
sudo dpkg-reconfigure --priority=low unattended-upgrades

# Reiniciar o MySQL para aplicar as configurações
sudo systemctl restart mysql