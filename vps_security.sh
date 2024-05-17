#!/bin/bash

# 设置变量
NEW_SSH_PORT=1234
NEW_USER="mibootore"
NEW_USER_PASSWORD="5^3ik7#XsZ3X&o"
HOSTNAME="srv1.mibootore.dns.navy"

# 检查是否以root用户运行
if [ "$(id -u)" -ne 0 ]; then
  echo "请以root用户运行此脚本。"
  exit 1
fi

# 设置主机名
echo "Setting hostname..."
echo "$HOSTNAME" > /etc/hostname
hostnamectl set-hostname "$HOSTNAME"

# 更新和升级系统
echo "Updating and upgrading system..."
apt update && apt upgrade -y && apt dist-upgrade -y && apt full-upgrade -y && apt autoremove -y

# 安装fail2ban
echo "Installing fail2ban..."
apt install fail2ban -y
systemctl start fail2ban

# 修改SSH端口
echo "Modifying SSH port..."
sed -i "s/#Port 22/Port $NEW_SSH_PORT/" /etc/ssh/sshd_config
if ! grep -q "^Port $NEW_SSH_PORT" /etc/ssh/sshd_config; then
  echo "Port $NEW_SSH_PORT" >> /etc/ssh/sshd_config
fi


# 添加新用户
echo "Adding new user..."
useradd -m "$NEW_USER"
echo "$NEW_USER:$NEW_USER_PASSWORD" | chpasswd

# 添加新用户到sudoers
echo "Adding new user to sudoers..."
echo "$NEW_USER ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/$NEW_USER
chmod 0440 /etc/sudoers.d/$NEW_USER

# 重启SSH服务
echo "Restarting SSH service..."
systemctl restart sshd

# 输出完成信息
echo "Configuration complete. Please login with the new user:"
echo "ssh $NEW_USER@$(hostname -I | awk '{print $1}') -p $NEW_SSH_PORT"



# 退出脚本
exit 0
