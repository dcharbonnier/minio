#!/usr/bin/python
import json
import os
import sys

access_key = sys.argv[1]
secret_key = sys.argv[2]
private_ips = sys.argv[3].split(',')
public_ips = sys.argv[4].split(',')
ids = sys.argv[5].split(',')

data = {
    "access_key": access_key,
    "secret_key": secret_key,
    "private_ips": private_ips,
    "public_ips": public_ips,
    "ids": ids
}

with open('minio.json', 'w') as outfile:
    json.dump(data, outfile)

os.system("curl -O https://dl.minio.io/client/mc/release/linux-amd64/mc")
os.system("chmod 700 mc")
os.system("chmod 600 /root/.ssh/id_rsa")
servers = " ".join(["http://%s.priv.cloud.scaleway.com/export" % id for id in ids])

os.system("ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa_local -q -N \"\" ")
for ip in public_ips:
    os.system(
        "scp -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no /root/.ssh/id_rsa_local.pub root@%s:/root/.ssh/instance_keys" % ip)
    os.system(
        "ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@%s scw-fetch-ssh-keys --upgrade" % ip)
    os.system("ssh -o StrictHostKeyChecking=no root@%s uptime" % ip)

os.system("mv /root/.ssh/id_rsa_local /root/.ssh/id_rsa")
count = 0
for ip in public_ips:
    data = {
        'count': count,
        'service_name': 'minio',
        'servers': servers,
        'ip': ip,
        'access_key': access_key,
        'secret_key': secret_key
    }
    command = '''
       ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
         root@%(ip)s
         'docker stop $(docker ps -a -q);
         docker rm $(docker ps -a -q);
         curl -L https://git.io/n-install | bash;
         mkdir /export;
         docker run
         -d
         -p 9000:9000
         --net=host
         -v /export
         --name %(service_name)s
         -e "MINIO_ACCESS_KEY=%(access_key)s"
         -e "MINIO_SECRET_KEY=%(secret_key)s"
         minio/minio:edge
         server %(servers)s'
        '''.replace('\n', '') % data
    os.system(command)
    os.system("./mc config host add minio-%(count)s http://%(ip)s:9000 %(access_key)s %(secret_key)s" % data)
    #os.system("root@%(ip)s wondershaper eth0 256 128" % data)
    count += 1
