# 项目功能

1. ubuntu/centos系统中nginx/php的安装
2. nginx配置文件，包括centos，ubuntu等系统中php，反向代理，子域名等环境设置
3. v2ray配置文件，包括windows和linux系统中负载均衡，反向代理，cloudflare warp等设置


# ubuntu安装PHP

**1. ubuntu系统中php的安装**

```
apt update
 
apt install php-fpm php-mysqlnd php-gd php-mbstring     # 安装php和一些常用扩展      

# apt install php php-cli php-fpm php-json php-common php-mysql php-zip php-gd php-mbstring php-curl php-xml php-pear php-bcmath

php -v                                                  # 查看php版本

systemctl enable php7.4-fpm

```

- ubuntu系统nginx配置文件路径

```
/etc/nginx/nginx.conf                # ubuntu系统配置文件路径
```

- nginx_ubuntu.conf：nginx在ubuntu系统中的配置文件，考虑了php，子域名等环境配置


**2. php配置文件**  

对于centos系统（digitalocean），php部分的配置为   
```
        location ~ \.php$ {
        	root /home/01_html;                                                                          # 注意修改php文件根目录
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
            root /home/01_html;                                                                            # 注意修改php文件根目录
#            try_files $uri =404;                                                                          # 删除
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;                                                    # 修改
#            fastcgi_index index.php;                                                                      # 删除
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            include snippets/fastcgi-php.conf;                                                             # 新增
        }
```
相比于centos，有删除，新增和修改。注意修改php文件根目录

php安装后的测试脚本

```
<?php
phpinfo();
```

将上述代码命名为 php-info.php

**3. 使用会话（session）跟踪用户登录状态**

```php
<?php
session_start();
// If the user is not logged in, redirect to the login page
if (!isset($_SESSION['loggedin']) || $_SESSION['loggedin'] !== true) {
  header('Location: login.php');
  exit;
}

// If the user clicked the logout link, log them out and redirect to the login page
if (isset($_GET['logout'])) {
  session_destroy(); // destroy all session data
  header('Location: login.php');
  exit;
}
```

1. 在PHP中，会话超时时间的设置在 `php.ini` 文件中。你可以搜索 `session.gc_maxlifetime` 这个配置项，它表示会话的最大生命周期，以秒为单位。默认值可能是比较小的，比如 1440 秒（24分钟）。

   - 对于ubuntu系统，`php.ini`通常位于`/etc/php/7.4/fpm/php.ini`目录，相关参数如下
    
    ```
    session.gc_maxlifetime = 3600
    ;       setting session.gc_maxlifetime to 1440 (1440 seconds = 24 minutes):
    ```
    
    查找相关关键词的命令如下
    ```
    grep  session.gc_maxlifetime  /etc/php/7.4/fpm/php.ini
    ```

   - 对于centos系统，`php.ini`通常位于`/etc/php.ini`目录

3. 如果你想延长会话的持续时间，你可以将这个值设置为更大的数值。比如，将其设置为 3600 表示会话在一个小时内不会过期。

4. 请记得在修改 `php.ini` 文件后，你需要重新启动你的 Web 服务器才能使修改生效。

```
systemctl restart nginx
```



# ubuntu安装nginx

1. 打开终端，使用sudo命令以管理员权限运行以下命令，更新软件包列表
```
sudo apt update                       
```

2. 安装Nginx
```
sudo apt install nginx                
```

3. 安装过程中，系统会要求你确认安装。按下Y键并按回车键继续安装。

4. 安装完成后，Nginx将自动启动。你可以使用以下命令检查Nginx的状态
``` 
sudo systemctl status nginx           
```
- 查看nginx版本

```
nginx -v
```

5. 设置开机自启动
```
sudo systemctl enable nginx           
```

6. 修改nginx配置文件

- 判断cenots系统中nginx配置文件语法是否正确的命令
```
nginx -t
```

- nginx配置文件路径
```
/etc/nginx/nginx.conf         # ubuntu系统
```

- 注意事项：   

ubuntu系统和centos系统的配置文件略有不同，总体一样，server中的部分基本可以复制，需要注意的地方会强调，比如    
```
user nginx;          # centos系统默认user
user www-data;       # ubuntu系统默认www-data
```



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

- **使用80端口的ubuntu/centos Nginx配置文件**

```
   server {
       listen 80;
       server_name 120.46.81.42;   # 服务器ip地址

       location / {
           root /home/01_html;       # 指定的服务器根目录，注意不要选择root目录，一般用home目录
           index /01_tecent1017/index.html;      # 访问ip默认显示的网页，该网页需要置于上述根目录下
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



# 参考资料

- https://blog.csdn.net/qq_45659165/article/details/128746568
