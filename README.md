# NetData从机安装脚本

安装命令

```shell
bash <(curl -s https://raw.githubusercontent.com/SilverIceKey/netdata_sub_machine_install/master/netdata_sub_machine_install.sh)
```

安装完成之后会输出需要在主服务器的/etc/netdata/stream.conf中需要配置的信息

如果不存在/etc/netdata/stream.conf则手动创建

输入完配置信息保存之后执行systemctl restart netdata