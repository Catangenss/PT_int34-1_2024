#!/bin/bash

# Обновление пакетов
echo "Updating package list..."
sudo apt update

# Установка необходимых пакетов
echo "Installing Python 3, pip, and sshpass..."
sudo apt-get install -y python3 python3-pip sshpass

# Настройка Python 3 в качестве основной версии Python
echo "Configuring Python alternatives..."
sudo update-alternatives --install /usr/bin/python python /usr/bin/python3 2

# Установка Ansible и passlib через pip
echo "Installing Ansible and passlib..."
sudo pip3 install ansible passlib

# Запрос данных у пользователя для инвентарного файла
echo "Enter ansible client data to write to inventory"
read -p "Enter client IP address: " client_ip
read -p "Enter client username: " client_username
read -sp "Enter client password: " client_password
echo

# Путь к файлу inventory
inventory_path="./inventory"

# Создание новых строк для inventory
new_line_debian_sudo="debian_sudo ansible_host=$client_ip ansible_user=$client_username ansible_password=$client_password ansible_become_pass=$client_password"
new_line_debian_ansible="debian_ansible ansible_host=$client_ip ansible_user=ansible ansible_password=ansible"

# Проверка, существует ли строка с "debian_sudo"
if grep -q '^debian_sudo' "$inventory_path"; then
    echo "Updating existing debian_sudo line in the inventory file..."
    sed -i "s|^debian_sudo.*|$new_line_debian_sudo|" "$inventory_path"
else
    echo "Adding new debian_sudo line to the inventory file..."
    echo "$new_line_debian_sudo" >> "$inventory_path"
fi

# Проверка, существует ли строка с "debian_ansible"
if grep -q '^debian_ansible' "$inventory_path"; then
    echo "Updating existing debian_ansible line in the inventory file..."
    sed -i "s|^debian_ansible.*|$new_line_debian_ansible|" "$inventory_path"
else
    echo "Adding new debian_ansible line to the inventory file..."
    echo "$new_line_debian_ansible" >> "$inventory_path"
fi

echo "Inventory file updated successfully."

# Запуск playbook Ansible
echo "Running Ansible playbook..."
ansible-playbook playbook.yml