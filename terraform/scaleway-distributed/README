# Before you start do this once
1. Create a scaleway account https://www.scaleway.com/
2. Due to an [issue](https://github.com/hashicorp/terraform/issues/9472)  with terraform you need to setup your custom private docker image **once**
  * create a VC1S with the docker image and wait for start
  * stop the server (archive) and create a snapshot called docker-for-terraform
  * on the images tab, create a new image from this snapshot and call it **docker**
  * you can now destroy this server
3. Create an ssh key and setup this key on your scaleway organisation
4. Create a file `terraform.tfvars` and add at least the organization, access_key and ssh\_private\_key values (for the ssh key use the `<<EOF\n... EOF\n` syntax

# Run terraform

`docker run -ti --rm -v `pwd`:/data --workdir=/data hashicorp/terraform:light apply`
