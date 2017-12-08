#cloud-config
manage_etc_hosts: True
runcmd:
  - sudo mkdir -p /filebeat/docker
  - sudo mkdir -p /filebeat/config/secrets
  - sudo mkdir -p /consul/config/secrets
  - sudo mkdir -p /nginx/config/secrets
  - sudo mkdir -p /nginx/logs
  - aws s3 cp s3://${bucket_name}/environments/${environment}/filebeat/ca_cert.pem /filebeat/config/secrets/ca_cert.pem
  - aws s3 cp s3://${bucket_name}/environments/${environment}/filebeat/filebeat_cert.pem /filebeat/config/secrets/filebeat_cert.pem
  - aws s3 cp s3://${bucket_name}/environments/${environment}/filebeat/filebeat_key.pem /filebeat/config/secrets/filebeat_key.pem
  - aws s3 cp s3://${bucket_name}/environments/${environment}/nginx/ca_and_server_cert.pem /nginx/config/secrets/ca_and_server_cert.pem
  - aws s3 cp s3://${bucket_name}/environments/${environment}/nginx/server_key.pem /nginx/config/secrets/server_key.pem
  - aws s3 cp s3://${bucket_name}/environments/${environment}/consul/ca_cert.pem /consul/config/secrets/ca_cert.pem
  - sudo usermod -aG docker ubuntu
  - sudo chmod -R ubuntu.ubuntu /nginx
  - sudo chmod -R ubuntu.ubuntu /consul
  - sudo chmod -R ubuntu.ubuntu /filebeat
  - export HOST_IP_ADDRESS=`ifconfig eth0 | grep "inet " | awk '{ print substr($2,6) }'`
  - sudo -u ubuntu docker run -d --name=consul --restart unless-stopped --net=host -e HOST_IP_ADDRESS=$HOST_IP_ADDRESS -v /consul/config:/consul/config consul:latest agent -bind=$HOST_IP_ADDRESS -client=$HOST_IP_ADDRESS -node=shop-webserver-$HOST_IP_ADDRESS
  - sudo -u ubuntu docker run -d --name=nginx --restart unless-stopped --net=host --privileged -v /nginx/config/nginx.conf:/etc/nginx/nginx.conf -v /nginx/logs:/var/log/nginx -v /nginx/config/secrets:/nginx/config/secrets nginx:latest
  - sudo -u ubuntu docker build -t filebeat:${filebeat_version} /filebeat/docker
  - sudo -u ubuntu docker run -d --name=filebeat --restart unless-stopped --net=host --log-driver json-file -v /filebeat/config/filebeat.yml:/usr/share/filebeat/filebeat.yml -v /filebeat/config/secrets:/filebeat/config/secrets -v /nginx/logs:/logs filebeat:${filebeat_version}
  - sudo sed -e 's/$HOST_IP_ADDRESS/'$HOST_IP_ADDRESS'/g' /tmp/10-consul > /etc/dnsmasq.d/10-consul
  - sudo service dnsmasq restart
write_files:
  - path: /consul/config/consul.json
    permissions: '0644'
    content: |
        {
          "ca_file": "/consul/config/secrets/ca_cert.pem",
          "verify_outgoing" : true,
          "enable_script_checks": true,
          "leave_on_terminate": true,
          "encrypt": "${consul_secret}",
          "retry_join": ["${consul_hostname}"],
          "datacenter": "${consul_datacenter}",
          "dns_config": {
            "allow_stale": true,
            "max_stale": "1s",
            "service_ttl": {
              "*": "5s"
            }
          }
        }
  - path: /etc/docker/daemon.json
    permissions: '0644'
    content: |
        {
          "log-driver": "syslog",
          "log-opts": {
            "tag": "Docker/{{.Name}}[{{.ImageName}}]({{.ID}})"
          }
        }
  - path: /filebeat/docker/Dockerfile
    permissions: '0755'
    content: |
        FROM docker.elastic.co/beats/filebeat:${filebeat_version}
        USER root
        RUN useradd -r syslog -u 104
        RUN usermod -aG adm filebeat
        USER filebeat
  - path: /consul/config/webserver.json
    permissions: '0644'
    content: |
        {
            "services": [{
                "name": "webserver-http",
                "tags": [
                    "http", "http"
                ],
                "port": 80,
                "checks": [{
                    "id": "1",
                    "name": "NGINX HTTP",
                    "notes": "Use nc to check the tcp port every 60 seconds",
                    "script": "nc -zv $HOST_IP_ADDRESS 80 >/dev/null 2>&1",
                    "interval": "60s"
                }]
            },{
                "name": "webserver-https",
                "tags": [
                    "tcp", "https"
                ],
                "port": 443,
                "checks": [{
                    "id": "1",
                    "name": "NGINX HTTPS",
                    "notes": "Use nc to check the tcp port every 60 seconds",
                    "script": "nc -zv $HOST_IP_ADDRESS 443 >/dev/null 2>&1",
                    "interval": "60s"
                }]
            }]
        }
  - path: /filebeat/config/filebeat.yml
    permissions: '0644'
    content: |
        filebeat.prospectors:
        - input_type: log
          paths:
          - /logs/*.log

        output.logstash:
          hosts: ["logstash.service.terraform.consul:5044"]
          ssl.certificate_authorities: ["/filebeat/config/secrets/ca_cert.pem"]
          ssl.certificate: "/filebeat/config/secrets/filebeat_cert.pem"
          ssl.key: "/filebeat/config/secrets/filebeat_key.pem"
  - path: /nginx/config/nginx.conf
    permissions: '0644'
    content: |
        worker_processes 4;
        worker_rlimit_nofile 8192;

        events {
          worker_connections 4096;
        }

        user www-data www-data;

        http {
          ssl_session_cache     shared:SSL:10m;
          ssl_session_timeout   10m;

          server {
            listen 80;
            server_name shop.${public_hosted_zone_name};
          	return 301 https://$$server_name$$request_uri;
          }

          server {
            listen 443 ssl;
            server_name shop.${public_hosted_zone_name};

            ssl_certificate     /nginx/config/secrets/ca_and_server_cert.pem;
            ssl_certificate_key /nginx/config/secrets/server_key.pem;
            ssl_protocols       TLSv1 TLSv1.1 TLSv1.2;
            ssl_ciphers         HIGH:!aNULL:!MD5;

            location /auth {
                resolver 127.0.0.1;
                set $upstream_auth auth.service.terraform.consul;
                proxy_pass https://$upstream_auth:3000$request_uri;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }

            location /api/designs {
                resolver 127.0.0.1;
                set $upstream_designs designs.service.terraform.consul;
                proxy_pass https://$upstream_designs:3001$request_uri;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }

            location /api/accounts {
                resolver 127.0.0.1;
                set $upstream_accounts accounts.service.terraform.consul;
                proxy_pass https://$upstream_accounts:3002$request_uri;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }

            location /watch {
                resolver 127.0.0.1;
                set $upstream_web web.service.terraform.consul;
                proxy_pass https://$upstream_web:8080$request_uri;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
                proxy_set_header Connection '';
                proxy_http_version 1.1;
                chunked_transfer_encoding off;
                proxy_buffering off;
                proxy_cache off;
            }

            location / {
                resolver 127.0.0.1;
                set $upstream_web web.service.terraform.consul;
                proxy_pass https://$upstream_web:8080$request_uri;
                proxy_set_header Host $host;
                proxy_set_header X-Real-IP $remote_addr;
                proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            }
          }
        }
  - path: /tmp/10-consul
    permissions: '0644'
    content: |
        server=/consul/$HOST_IP_ADDRESS#8600
