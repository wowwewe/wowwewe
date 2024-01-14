#!/bin/bash
function blue(){
    echo -e "\033[34m\033[01m$1\033[0m"
}
function green(){
    echo -e "\033[32m\033[01m$1\033[0m"
}
function red(){
    echo -e "\033[31m\033[01m$1\033[0m"
}
function yellow(){
    echo -e "\033[33m\033[01m$1\033[0m"
}
green "======================="
blue "请输入用于ssh连接的端口号"
blue "请注意不要重复使用端口"
green "======================="
read ssh_port 
green "======================="
blue "请输入ssh证书公钥"
green "======================="
read ssh_pub

sudo mv /root/.ssh/authorized_keys /root/.ssh/authorized_keys.b

sudo cat > /root/.ssh/authorized_keys<<-EOF
$ssh_pub
EOF
sudo mv /etc/ssh/sshd_config /etc/ssh/sshd_config.b
sudo cat > /etc/ssh/sshd_config<<-EOF
# 端口, 默认22
Port $ssh_port
# 监听地址相关, 不需修改
#AddressFamily any
#ListenAddress 0.0.0.0
#ListenAddress ::
# Ciphers and keying
#RekeyLimit default none
# 日志
# 指定将日志消息通过哪个日志子系统(facility)发送
SyslogFacility AUTH
# 指定日志等级
LogLevel INFO
# 鉴权
# 限制用户必须在指定的时限(单位秒)内认证成功
LoginGraceTime 2m
# 允许root用户登录
PermitRootLogin yes
# 指定是否要求sshd(8)在接受连接请求前对用户主目录和相关的配置文件进行宿主和权限检查
StrictModes yes
# 指定每个连接最大允许的认证次数
MaxAuthTries 6
# 最大允许保持多少个连接。默认值是 10
MaxSessions 16
# 是否开启公钥认证, 仅可以用于SSH-2. 默认值为"yes"
PubkeyAuthentication yes
# 是否允许密码验证
PasswordAuthentication no
# 是否允许空密码
PermitEmptyPasswords no
# 是否允许质疑-应答(challenge-response)认证
ChallengeResponseAuthentication no
# 是否通过PAM验证
UsePAM yes
# 是否允许X11转发
X11Forwarding yes
#X11DisplayOffset 10
#X11UseLocalhost yes
# 指定sshd是否在每一次交互式登录时打印 /etc/motd 文件的内容
PrintMotd no
# 指定sshd是否在每一次交互式登录时打印最后一位用户的登录时间
PrintLastLog yes
# 配置超时
TCPKeepAlive yes
ClientAliveInterval 120
ClientAliveCountMax 10
# 配置Pid
PidFile /var/run/sshd.pid
# Allow client to pass locale environment variables
AcceptEnv LANG LC_*
# override default of no subsystems
Subsystem sftp /usr/lib/openssh/sftp-server
EOF
sudo service sshd restart

green "ssh端口已更改为$ssh_port"
green "请使用root账户登录"