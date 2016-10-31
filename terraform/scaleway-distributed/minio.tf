provider "scaleway" {
  organization = "${var.organization}"
  access_key = "${var.access_key}"
}

data "scaleway_image" "docker" {
  architecture = "x86_64"
  name = "docker"
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
      "/etc/init.d/docker restart"
    ]
  }
}
resource "null_resource" "bootstrap1" {
  triggers {
    cluster_instance_ids = "${join(",", scaleway_server.minio.*.id)}"
  }
  connection {
    host = "${element(scaleway_server.minio.*.public_ip, 0)}"
    private_key = "${var.ssh_private_key}"
  }
  provisioner "file" {
      source = "./bootstrap.py"
      destination = "/root/bootstrap.py"
  }
  provisioner "remote-exec" {
    inline = [
      "echo '${var.ssh_private_key}' > /root/.ssh/id_rsa",
      "python /root/bootstrap.py ${var.minio_access_key} ${var.minio_secret_key} ${join(",", scaleway_server.minio.*.private_ip)}  ${join(",", scaleway_server.minio.*.public_ip)} ${join(",", scaleway_server.minio.*.id)}"
    ]
  }
}