# Nginx + Consul Template

## Usage

Consul Template updates Nginx configurations and sends SIGHUP for reloading:

```
$ docker-compose up
...
nginx_1       | 2016/05/21 16:15:21 [notice] 14#0: signal 1 (SIGHUP) received, reconfiguring
nginx_1       | 2016/05/21 16:15:21 [notice] 14#0: reconfiguring
nginx_1       | 2016/05/21 16:15:21 [notice] 14#0: using the "epoll" event method
nginx_1       | 2016/05/21 16:15:21 [notice] 14#0: start worker processes
nginx_1       | 2016/05/21 16:15:21 [notice] 14#0: start worker process 26
nginx_1       | 2016/05/21 16:15:26 [notice] 22#0: gracefully shutting down
nginx_1       | 2016/05/21 16:15:26 [notice] 22#0: exiting
nginx_1       | 2016/05/21 16:15:26 [notice] 22#0: exit
nginx_1       | 2016/05/21 16:15:26 [notice] 14#0: signal 17 (SIGCHLD) received
nginx_1       | 2016/05/21 16:15:26 [notice] 14#0: worker process 22 exited with code 0
nginx_1       | 2016/05/21 16:15:26 [notice] 14#0: signal 29 (SIGIO) received
...
```

New configurations are generated like this:

```
$ docker exec -it nginx_nginx_1 cat /etc/nginx/conf.d/default.conf

## Service: app
upstream app {
  least_conn;
  server 172.21.0.5:8080 max_fails=3 fail_timeout=60 weight=1;

}

server {
  listen 80;
  server_name app.example.com;

  proxy_set_header Host $host;
  proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
  proxy_set_header X-Forwarded-Host $host;
  proxy_set_header X-Forwarded-Server $host;
  proxy_set_header X-Real-IP $remote_addr;

  location /favicon {
    empty_gif;
    access_log off;
    log_not_found off;
  }

  location / {
    proxy_pass http://app;
  }
}


## Service: Consul UI
server {
  listen 80 default_server;
  server_name _;

  location /favicon {
    empty_gif;
    access_log off;
    log_not_found off;
  }

  location /nginx_status {
    stub_status on;
    allow 127.0.0.1;
    allow 172.17.0.1;
    deny all;
  }

  location / {
     proxy_pass http://consul:8500;
  }
}
```

Nginx routes requests to `app.example.com` correctly.

```
$ curl -s -H "Host: app.example.com" http://192.168.99.100/
app
```
