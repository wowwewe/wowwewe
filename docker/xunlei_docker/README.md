# 迅雷远程下载服务(docker)(非官方)
# fork自 [cnk3x/xunlei](https://github.com/cnk3x/xunlei/tree/docker)
## 编译方法

去 [https://nas.xunlei.com](https://nas.xunlei.com)下载迅雷群晖套件的SPK文件放到 SPK 目录
确保含有 *-armv8.spk 或者 *-x86_64.spk
比如: 
```
spk
├── nasxunlei-DSM7-armv8.spk
└── nasxunlei-DSM7-x86_64.spk
```
然后
```bash

docker buildx build -t 你的docker用户名/xunlei ./

例如：
docker buildx build -t aaa/xunlei ./
```

从迅雷群晖套件中提取出来用于其他设备的迅雷远程下载服务程序。仅供测试，测试完请大家自觉删除。

下载保存目录 `/xunlei/data`， 对应迅雷应用内显示的下载路径是 `/downloads` 或者 `/迅雷下载`

- 环境变量 `XL_WEB_PORT`: 网页访问端口，默认 `2345`。
- 环境变量 `XL_DEBUG`: 1 为调试模式，输出详细的日志信息，0: 关闭，不显示迅雷套件输出的日志，默认0.
- 环境变量 `UID`, `GID`, 设定运行迅雷下载的用户，使用此参数注意下载目录必须是该账户有可写权限。
- 环境变量 `XL_BA_USER` 和 `XL_BA_PASSWORD`: 给迅雷面板添加基本验证（明码）。 #57
- `host` 网络下载速度比 `bridge` 快, 如果没有条件使用host网络，映射`XL_WEB_PORT`设定的端口`tcp`即可。
- 下载保存目录 `/xunlei/downloads`, 数据目录：`/xunlei/data`, 请持久化。
- `hostname`: 迅雷会以主机名来命名远程设备，你在迅雷App上看到的就是这个。
- ~~安装好绑定完后可以在线升级到迅雷官方最新版本~~ 这点不确定了，得自己尝试。

## docker shell

```bash
# 以下以 /mnt/sdb1/downloads 为实际的下载保存目录 /mnt/sdb1/xunlei 为实际的数据保存目录 为例 根据实际情况更改
# 必须给予最高权限 --privileged
# 如果已经安装过的(/mnt/sdb1/xunlei 目录已存在)，再次安装会复用，而且下载目录不可更改，如果要更改下载目录，请把这个目录删掉重新绑定。

# host网络，默认端口 2345
docker run -d --name=xunlei --hostname=mynas --net=host -v /mnt/sdb1/xunlei:/xunlei/data -v /mnt/sdb1/downloads:/xunlei/downloads --restart=unless-stopped --privileged wowaqly/xunlei:latest

# host网络，更改端口为 4321
docker run -d --name=xunlei --hostname=mynas --net=host -e XL_WEB_PORT=4321 -v /mnt/sdb1/xunlei:/xunlei/data -v /mnt/sdb1/downloads:/xunlei/downloads --restart=unless-stopped --privileged wowaqly/xunlei:latest

# bridge 网络，默认端口 2345
docker run -d --name=xunlei --hostname=mynas --net=bridge -p 2345:2345 -v /mnt/sdb1/xunlei:/xunlei/data -v /mnt/sdb1/downloads:/xunlei/downloads --restart=unless-stopped --privileged wowaqly/xunlei:latest

# bridge 网络，更改端口为 4321
docker run -d --name=xunlei --hostname=mynas --net=bridge -p 4321:2345 -v /mnt/sdb1/xunlei:/xunlei/data -v /mnt/sdb1/downloads:/xunlei/downloads --restart=unless-stopped --privileged wowaqly/xunlei:latest
```


## 已知问题

插件无法使用

## systemd 服务版本

<https://github.com/cnk3x/xunlei/tree/main>
