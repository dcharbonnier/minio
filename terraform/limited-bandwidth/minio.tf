provider "scaleway" {
  organization = "${var.organization}"
  access_key = "${var.access_key}"
}

data "scaleway_image" "docker" {
  architecture = "x86_64"
  name = "Docker"
}

resource "scaleway_server" "test" {
  name = "minio-test"
  image = "${data.scaleway_image.docker.id}"
  type = "${var.type}"
  dynamic_ip_required = true
  connection {
    private_key = "${var.ssh_private_key}"
  }
  provisioner "file" {
      source = "./bootstrap.py"
      destination = "/root/bootstrap.py"
  }
   provisioner "file" {
      source = "./client/"
      destination = "/root/"
  }
  provisioner "remote-exec" {
    inline = [
      "hostname minio-test",
      "/etc/init.d/docker restart",
      "head -c 100000000 </dev/urandom >/root/randomfile",
      "curl -sL https://git.io/n-install | bash -s -- -q",
      "cd /root && npm install",
      "echo '${var.ssh_private_key}' > /root/.ssh/id_rsa",
      "python /root/bootstrap.py ${var.minio_access_key} ${var.minio_secret_key} ${join(",", scaleway_server.minio.*.private_ip)}  ${join(",", scaleway_server.minio.*.public_ip)} ${join(",", scaleway_server.minio.*.id)}"
    ]
  }
}

output "server" {
  value = "${scaleway_server.test.public_ip}"
}

resource "scaleway_server" "minio" {
  count = "${var.servers}"
  name = "minio-${count.index}"
  image = "${data.scaleway_image.docker.id}"
  type = "${var.type}"
  dynamic_ip_required = true
  connection {
    private_key = "${var.ssh_private_key}"
  }
  provisioner "remote-exec" {
    inline = [
      "hostname minio-${count.index}",
      "systemctl stop apt-daily.timer",
      "systemctl stop apt-daily.service",
      "dpkg --configure -a",
      "apt-get install -y wondershaper nload",
      "/etc/init.d/docker restart"
    ]
  }
}

output "minio" {
  value = "${join(",", scaleway_server.minio.*.public_ip)}"
}