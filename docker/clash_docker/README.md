```shell
docker run -d -v /xxx/config.yaml:/root/clash/config/config.yaml -p 1234:7890 -p 123:80 -p 9090:9090 --name=clash --restart=always wowaqly/clash
```

cinfig.yaml 必须 
```shell
external-controller: 0.0.0.0:9090
```

## 参数

|名称               |说明                                                   |
|:-                 |:-                                                     |
|`CLASH_REVE`       |版本号，默认：2023.02.16                                  |
|`APT_SOURCE_HOST`  |Apt更新源地址，默认为华为云镜像：mirrors.huaweicloud.com   |

*更多参数设置，请参考：<https://github.com/jlesage/docker-baseimage-gui>*



