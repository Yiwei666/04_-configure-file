# 1. 项目功能

1. windows和linux端xray配置文件


# 2. 文件结构

```
xray_vless_win_route.json            # windows端、包含http和socks5入口协议，支持根据域名进行分流
xray_vless_win_route_IP.json         # windows端、包含http和socks5入口协议，支持根据域名、IP地址进行分流
```


### 1. xray_vless_win_route_IP.json

1. **domainStrategy**

这一参数的作用是：当某个域名没有命中前面的域名分流规则时，Xray 可以尝试解析其 IP，再判断是否符合 geoip:cn 等 IP 分流规则。
例如，一个网站虽然未被收录进 geosite:cn，但解析出的 IP 属于中国大陆，也有机会被识别为直连流量。

代价是部分请求需要额外的 DNS 查询，可能增加连接延迟，也需要留意本地 DNS 的使用和隐私问题。

```json
"domainStrategy": "IPIfNonMatch"
```

这表示 Xray 会先按原始目标信息遍历规则。如果没有任何规则命中，且目标是域名，才可能解析域名并进行第二轮 IP 匹配。因此，指定域名规则一旦命中，就不会再因为该域名解析出的 IP 而改变分流结果。


2. 使用 domain: 前缀

```json
// 按子字符串匹配
"domain": ["baidu.com", "nature.com"]

// 
"domain": [
  "domain:baidu.com",
  "domain:nature.com"
]
```

`baidu.com`：按子字符串匹配，有可能误匹配包含该字符串的其他域名。
`domain:baidu.com`：只匹配 `baidu.com` 本身及其子域名，如 `www.baidu.com`。

