#!/bin/bash

# 设置变量
NEW_SSH_PORT=1234
NEW_USER="mibootore"
NEW_USER_PASSWORD="m1b00t0re"

#主机名
echo “srv1.mibootore.dns.navy” > /etc/hostname

sudo apt install fail2ban -y
sudo service fail2ban start


# 修改SSH端口
echo "Modifying SSH port..."
sudo sed -i "s/#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config

# 禁用root登录
echo "Disabling root login..."
sudo sed -i "s/#PermitRootLogin yes/PermitRootLogin no/" /etc/ssh/sshd_config

# 重启SSH服务
echo "Restarting SSH service..."
sudo service sshd restart

# 添加新用户
echo "Adding new user..."
sudo useradd -m $NEW_USER
echo "$NEW_USER:$NEW_USER_PASSWORD" | sudo chpasswd

# 添加新用户到sudoers
echo "Adding new user to sudoers..."
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/$NEW_USER

# 输出完成信息
echo "Configuration complete. Please login with the new user:"
echo "ssh $NEW_USER@$(hostname -I | awk '{print $1}') -p $NEW_SSH_PORT"

# 退出脚本
exit 0
