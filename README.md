# 1. 项目功能

1. ubuntu/centos系统中nginx/php的安装
2. nginx配置文件，包括centos，ubuntu等系统中php，反向代理，子域名等环境设置
3. v2ray配置文件，包括windows和linux系统中负载均衡，反向代理，cloudflare warp等设置


# 2. ubuntu安装PHP

### 1. ubuntu系统中php的安装

```bash
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


### 2. php配置文件

#### 1. centos系统中php环境配置

注意：
1. 对于centos，首先核对`/var/run/php-fpm/www.sock`路径下，是否存在 `www.sock` 文件

```sh
ls /var/run/php-fpm/
```

2. 如果该路径下不存在`www.sock`文件，需要在PHP-FPM配置文件 `/etc/php-fpm.d/www.conf` 中找到listen选项，然后listen值作为fastcgi_pass。

```sh
find /etc -name "www.conf"                  # 查找 /etc 文件夹下 www.conf 配置文件的位置

grep listen /etc/php-fpm.d/www.conf         # 查找 www.conf 中 listen关键词
```

相应地，在 `/etc/php-fpm.d/www.conf` 文件中也能找到 liste对应值为 `listen = listen = 127.0.0.1:9000`

```ini
;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific address on
;   'port'                 - to listen on a TCP socket to all addresses on a
;   '/path/to/unix/socket' - to listen on a unix socket.
listen = 127.0.0.1:9000
; Set listen(2) backlog. A value of '-1' means unlimited.
;listen.backlog = -1
; PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
listen.allowed_clients = 127.0.0.1
;listen.owner = nobody
;listen.group = nobody
;listen.mode = 0666
listen.owner = nginx
listen.group = nginx
```

对于 centos系统（digitalocean）中nginx配置部分，相应php部分的配置为   

```nginx
        location ~ \.php$ {
            root /home/01_html;
            try_files $uri =404;
            fastcgi_pass 127.0.0.1:9000;
            fastcgi_index index.php;
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            client_max_body_size 5M;                                                     # 默认允许nignx客户端上传的请求体、如文件, 最大为1MB
        }

```

3. 如果该路径下存在`www.sock`文件，可以在按照如下语法在nginx配置文件中进行location添加。

```nginx
        location ~ \.php$ {
        	root /home/01_html;                                                         # 注意修改php文件根目录
        	try_files $uri =404;
        	fastcgi_pass unix:/var/run/php-fpm/www.sock;
        	fastcgi_index index.php;
        	fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        	include fastcgi_params;
         client_max_body_size 5M;                                                     # 默认允许nignx客户端上传的请求体、如文件, 最大为1MB
        }
```

相应地，在 `/etc/php-fpm.d/www.conf` 文件中也能找到 liste对应值为`listen = /run/php-fpm/www.sock` 

```ini
(base) [root@centos-s-1vcpu-2gb-nyc1-01 05_douyinAsynDload]# grep listen /etc/php-fpm.d/www.conf
; - 'listen' (unixsocket)
;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific IPv4 address on
;   '[ip:6:addr:ess]:port' - to listen on a TCP socket to a specific IPv6 address on
;   'port'                 - to listen on a TCP socket to all addresses
;   '/path/to/unix/socket' - to listen on a unix socket.
listen = /run/php-fpm/www.sock
; Set listen(2) backlog.
;listen.backlog = 511
listen.owner = nginx
listen.group = nginx
;listen.mode = 0660
; When set, listen.owner and listen.group are ignored
listen.acl_users = apache,nginx
;listen.acl_groups =
; PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
listen.allowed_clients = 127.0.0.1
;   listen queue         - the number of request in the queue of pending
;                          connections (see backlog in listen(2));
;   max listen queue     - the maximum number of requests in the queue
;   listen queue len     - the size of the socket queue of pending connections;
;   listen queue:         0
;   max listen queue:     1
;   listen queue len:     42
```


#### 2. ubuntu系统中php环境配置

1. 对于 ubuntu，首先核对`/run/php/php7.4-fpm.sock`路径

```sh
ls /run/php/

find /run -name "php7.4-fpm.sock"
```

2. 如果该路径下不存在`php7.4-fpm.sock`文件，需要在PHP-FPM配置文件 `/etc/php/7.4/fpm/pool.d/www.conf` 中找到listen选项，然后listen值作为fastcgi_pass。

相关查找和查看命令如下

```sh
find /etc -name "www.conf"                          # 查找 /etc 文件夹下 www.conf 配置文件的位置

grep listen /etc/php/7.4/fpm/pool.d/www.conf        # 查找 www.conf 中 listen关键词
```
 
3. 如果该路径下存在`php7.4-fpm.sock`文件，可以在按照如下语法在nginx配置文件中进行location添加。

对于ubuntu系统（azure），php部分的配置为

```nginx
        location ~ \.php$ {
            root /home/01_html;                                                                            # 注意修改php文件根目录
#            try_files $uri =404;                                                                          # 删除
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;                                                    # 修改
#            fastcgi_index index.php;                                                                      # 删除
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            include snippets/fastcgi-php.conf;                                                             # 新增
            client_max_body_size 5M;                                                                       # 默认允许nignx客户端上传的请求体、如文件, 最大为1MB
        }
```

相应地，在 `/etc/php/7.4/fpm/pool.d/www.conf` 文件中也能找到 liste对应值为`listen = /run/php/php7.4-fpm.sock` 

```ini
(base) root@hcss-ecs-f0c3:/home# grep listen /etc/php/7.4/fpm/pool.d/www.conf
; - 'listen' (unixsocket)
;   'ip.add.re.ss:port'    - to listen on a TCP socket to a specific IPv4 address on
;   '[ip:6:addr:ess]:port' - to listen on a TCP socket to a specific IPv6 address on
;   'port'                 - to listen on a TCP socket to all addresses
;   '/path/to/unix/socket' - to listen on a unix socket.
listen = /run/php/php7.4-fpm.sock
; Set listen(2) backlog.
;listen.backlog = 511
listen.owner = www-data
listen.group = www-data
;listen.mode = 0660
; When set, listen.owner and listen.group are ignored
;listen.acl_users =
;listen.acl_groups =
; PHP FCGI (5.2.2+). Makes sense only with a tcp listening socket. Each address
;listen.allowed_clients = 127.0.0.1
;   listen queue         - the number of request in the queue of pending
;                          connections (see backlog in listen(2));
;   max listen queue     - the maximum number of requests in the queue
;   listen queue len     - the size of the socket queue of pending connections;
;   listen queue:         0
;   max listen queue:     1
;   listen queue len:     42
```

相比于centos，`www.conf` 配置文件的路径是不一样的，`location ~ \.php`有删除，新增和修改。注意修改php文件根目录


- php安装后的测试脚本

```php
<?php
phpinfo();
```

将上述代码命名为 php-info.php


### 3. 配置`php.ini`使用会话（session）跟踪用户登录状态

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

   - 对于ubuntu系统，`php.ini`通常位于`/etc/php/7.4/fpm/php.ini`目录，

     相关参数如下：
    
     ```
     session.gc_maxlifetime = 3600
     ;       setting session.gc_maxlifetime to 1440 (1440 seconds = 24 minutes):
     ```
    
     查找相关关键词的命令如下
   
     ```
     grep  session.gc_maxlifetime  /etc/php/7.4/fpm/php.ini
     ```

   - 对于centos系统，`php.ini`通常位于`/etc/php.ini`目录

2. 如果你想延长会话的持续时间，你可以将这个值设置为更大的数值。比如，将其设置为 3600 表示会话在一个小时内不会过期。

3. 请记得在修改 `php.ini` 文件后，你需要重新启动你的 Web 服务器才能使修改生效。

```sh
systemctl restart nginx
```

4. **重启 PHP-FPM 服务才能够使上述 `php.ini` 的修改生效**

```sh
service php7.4-fpm restart
```

仅重启nginx的web服务是不能够使其生效的



# 3. ubuntu安装nginx

### 1. 安装命令

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



### 2. nginx配置文件中同时使用主域名和子域名

```nginx
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

```nginx
   server {
       listen 80;
       server_name 120.46.81.42;   # 服务器ip地址

       location / {
           root /home/01_html;       # 指定的服务器根目录，注意不要选择root目录，一般用home目录
           index /01_tecent1017/index.html;      # 访问ip默认显示的网页，该网页需要置于上述根目录下
       }
}
```



### 3. 将`localhost:8000`端口服务反向代理到`api.domian.com`子域名

如果服务使用docker应用提供，那么docker应用配置文件中的域名也应当改为子域名，子域名server中ssl/tls证书路径可以使用与主域名相同的路径

```nginx
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

### 4.  设置 nginx 允许客户端上传的请求体（包括文件上传）的最大大小

在 NGINX 配置文件`/etc/nginx/nginx.conf`（ubuntu）中，`client_max_body_size` 参数的默认值通常是1m，表示1兆字节。这意味着默认情况下 NGINX 允许客户端上传的请求体（包括文件上传）的最大大小为1兆字节。

如果没有显式地在配置文件中设置 client_max_body_size，NGINX 将使用这个默认值。如果你需要允许更大的请求体大小，你可以在 NGINX 的配置文件中显式地设置这个参数，如前面所述。

```
client_max_body_size 5M;                                                     # 默认允许nignx客户端上传的请求体、如文件, 最大为1MB
```

修改该参数后请重启nginx

```
sudo systemctl restart nginx
```


1. 写在`server`块内

如果你想对整个服务器的所有请求设置相同的 `client_max_body_size`，可以将其写在 server 块内。这样会影响该服务器上的所有站点。

```nginx
server {
    # 其他配置项...

    client_max_body_size 5M; # 将5M替换为你期望的最大请求体大小

    location / {
        # 其他配置项...
    }
}
```


2. 写在`location`块内

如果你只想对特定的路径或虚拟主机设置 `client_max_body_size`，则可以将其写在相应的 location 块内。

```nginx
server {
    # 其他配置项...

    location /upload {
        client_max_body_size 5M; # 将5M替换为你期望的最大请求体大小

        # 其他配置项...
    }

    location / {
        # 其他配置项...
    }
}
```

在这个例子中，client_max_body_size 只会影响 /upload 路径下的请求。

- 以ubuntu系统中php脚本的请求为例

```nginx
        location ~ \.php$ {
            root /home/01_html/;                                                                           # 注意修改php文件根目录
            fastcgi_pass unix:/run/php/php7.4-fpm.sock;                                                    # 修改
            fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
            include fastcgi_params;
            include snippets/fastcgi-php.conf;                                                             # 新增
            client_max_body_size 5M;                                                                       # 默认允许nignx客户端上传的请求体、如文件, 最大为1MB
        }
```


3. 更改 `php.ini` 中对于文件上传大小的限制

- `upload_max_filesize`和`post_max_size`含义
   - 这两个参数都是用于限制通过 HTTP POST 请求上传到服务器的数据量的 PHP 配置项。当你在 PHP 配置文件（通常是 php.ini 文件）中设置这两个参数时，需要确保将它们设置为相同或更大的值，以便 post_max_size 能够容纳。
   - `upload_max_filesize`：该参数限制了单个文件上传的最大大小。通常默认值是较小的值，例如 2M，表示允许上传最大为2兆字节（2MB）的文件。如果用户尝试上传一个超过该大小的文件，上传请求将被拒绝。
   - `post_max_size`：该参数限制了整个 POST 请求的最大大小，包括除了文件上传之外的所有 POST 数据。通常默认值也是较小的值，例如 8M，表示整个 POST 请求的最大大小为8兆字节（8MB）。
 
- ubuntu查看`upload_max_filesize`和`post_max_size`参数命令

```sh
grep  upload_max_filesize  /etc/php/7.4/fpm/php.ini

grep  post_max_size  /etc/php/7.4/fpm/php.ini
```

`upload_max_filesize`和`post_max_size`默认值分别 2M 和 8M，可修改为 6MB 和 24MB

```ini
; Maximum size of POST data that PHP will accept.
; http://php.net/post-max-size
post_max_size = 8M
; Maximum allowed size for uploaded files.
; http://php.net/upload-max-filesize
upload_max_filesize = 2M
```

- **重启 PHP-FPM 服务才能够使上述 `php.ini` 的修改生效**

```sh
service php7.4-fpm restart
```

仅重启nginx的web服务是不能够使其生效的


# 4. v2ray配置文件

linux中v2ray配置文件路径，配置方案：VMess-WS-TLS 
```
/usr/local/etc/v2ray/config.json                       # centos中v2ray配置文件路径

jq . /usr/local/etc/v2ray/config.json                  # 部分校验语法正确性


```


warp/v2ray配置文件

[uuid generator](https://www.uuidgenerator.net/)


# sub.sh

超算提交脚本



# 参考资料

- https://blog.csdn.net/qq_45659165/article/details/128746568
