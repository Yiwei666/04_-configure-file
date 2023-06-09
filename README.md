### 项目功能
```
01 nginx配置文件，包括centos，ubuntu等系统中php，反向代理，子域名等环境设置
02 v2ray配置文件，包括windows和linux系统中负载均衡，反向代理，cloudflare warp等设置
```

### nginx配置文件

判断cenots系统中nginx配置文件语法是否正确的命令
```
nginx -t
```

nginx配置文件路径
```
/etc/nginx/nginx.conf         # ubuntu系统
```

注意事项：   
1. ubuntu系统和centos系统的配置文件略有不同，总体一样，server中的部分基本可以复制，需要注意的地方会强调，比如    
```
user nginx;          # centos系统默认user
user www-data;       # ubuntu系统默认www-data
```

**2. php配置文件**  

对于centos系统（digitalocean），php部分的配置为   
```
        location ~ \.php$ {
        	root /home/01_dir;                                                                                # 替换
        	try_files $uri =404;
        	fastcgi_pass unix:/var/run/php-fpm/www.sock;
        	fastcgi_index index.php;
        	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        	include fastcgi_params;
        }
```

对于ubuntu系统（azure），php部分的配置为
```
        location ~ \.php$ {
            root /home/01_dir;
#            try_files $uri =404;                                                                          # 删除
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;                                                    # 修改
#            fastcgi_index index.php;                                                                      # 删除
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            include snippets/fastcgi-php.conf;                                                             # 新增
        }
```
相比于centos，有删除，新增和修改

**3. nginx配置文件中同时使用主域名和子域名**
```
server {
    listen 443 ssl;
    server_name example.com www.example.com;
    
    ssl_certificate /path/to/ssl_certificate.crt;
    ssl_certificate_key /path/to/ssl_certificate.key;
    
    location / {
        # 主域名的请求处理逻辑
        ...
    }
}

server {
    listen 443 ssl;
    server_name subdomain.example.com;
    
    ssl_certificate /path/to/ssl_certificate.crt;
    ssl_certificate_key /path/to/ssl_certificate.key;
    
    location / {
        # 子域名的请求处理逻辑
        ...
    }
}

```

**4. 例如将本地回环地址8000端口的服务反向代理到api.domian.com子域名上**  

如果服务使用docker应用提供，那么docker应用配置文件中的域名也应当改为子域名，子域名server中ssl/tls证书路径可以使用与主域名相同的路径

```
    server {
        listen 443 ssl;
        server_name api.domain.com; # 替换为您的域名
        ssl_certificate /etc/nginx/key_crt/domain.com.crt; # 替换为您下载的证书文件路径
        ssl_certificate_key /etc/nginx/key_crt/domain.com.key; # 替换为您下载的密钥文件路径
        ssl_protocols TLSv1.2 TLSv1.3; # 选择您需要支持的 SSL/TLS 协议版本

        location / {
            proxy_pass http://127.0.0.1:8000; # 替换为您Node.js应用的监听地址
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection "upgrade";
        }
    }
```


### v2ray配置文件

linux中v2ray配置文件路径，配置方案：VMess-WS-TLS 
```
/usr/local/etc/v2ray/config.json                       # centos中v2ray配置文件路径

jq . /usr/local/etc/v2ray/config.json                  # 部分校验语法正确性


```


warp/v2ray配置文件

[uuid generator](https://www.uuidgenerator.net/)


### sub.sh
超算提交脚本
