#!/usr/bin/python
import sys, os
try:
    access_key = sys.argv[1]
    secret_key = sys.argv[2]
    private_ips = sys.argv[3].split(',')
    public_ips = sys.argv[4].split(',')
    ids = sys.argv[5].split(',')

    os.system("chmod 600 /root/.ssh/id_rsa")
    servers = " ".join([ "http://%s.priv.cloud.scaleway.com/minio" % id for id in ids ])

    for ip in public_ips:
       command = '''
           ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no
             root@%(ip)s
             'docker stop $(docker ps -a -q);
             docker rm $(docker ps -a -q);
             mkdir /minio;
             docker run
             -d
             -p 9000:9000
             --net=host
             -v /minio
             --name %(service_name)s
             -e "MINIO_ACCESS_KEY=%(access_key)s"
             -e "MINIO_SECRET_KEY=%(secret_key)s"
             minio/minio:edge
             server %(servers)s'
            '''.replace('\n', '') % {
                'service_name' : 'minio',
                'servers':servers,
                'ip':ip,
                'access_key': access_key,
                'secret_key': secret_key
            }
       os.system(command)
finally:
    os.system("rm /root/.ssh/id_rsa")
    os.system("rm /root/bootstrap.py")
