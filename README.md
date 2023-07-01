### 项目功能


### nginx配置文件
判断cenots系统中nginx配置文件语法是否正确的命令
```
nginx -t
```

注意事项：   
1. ubuntu系统和centos系统的配置文件略有不同，总体一样，server中的部分基本可以复制，需要注意的地方会强调，比如    
```
user nginx;          # centos系统默认user
user www-data;       # ubuntu系统默认www-data
```

2. php配置文件  

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

### 04_warp-v2ray-
warp/v2ray配置文件

[uuid generator](https://www.uuidgenerator.net/)


### sub.sh
超算提交脚本
