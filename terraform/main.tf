terraform {
  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0"
    }
  }
}

provider "docker" {}

############################
# Network and Volume
############################

resource "docker_network" "app_net" {
  name = "${var.project_name}-net"
}

resource "docker_volume" "html" {
  name = "${var.project_name}-html"
}

############################
# Local config files
############################

resource "local_file" "nginx_conf" {
  filename = "${path.module}/files/nginx.conf"
  content = templatefile("${path.module}/files/nginx.conf", {
    app_env = var.app_env
  })
}

resource "local_file" "index_php" {
  filename = "${path.module}/files/index.php"
  content  = file("${path.module}/files/index.php")
}

############################
# PHP-FPM container
############################

resource "docker_container" "php" {
  name  = "${var.project_name}-php-fpm"
  image = "php:8.2-fpm"

  networks_advanced {
    name    = docker_network.app_net.name
    aliases = ["php-fpm"]
  }

  volumes {
    volume_name    = docker_volume.html.name
    container_path = "/var/www/html"
  }
}

############################
# Nginx container
############################

resource "docker_container" "nginx" {
  name  = "${var.project_name}-nginx"
  image = "nginx:latest"

  networks_advanced {
    name = docker_network.app_net.name
  }

  ports {
    internal = 80
    external = var.host_port
  }

  volumes {
    volume_name    = docker_volume.html.name
    container_path = "/var/www/html"
  }

  mounts {
    target = "/etc/nginx/conf.d/default.conf"
    type   = "bind"
    source = "${path.module}/files/nginx.conf"
  }


  depends_on = [docker_container.php]
}
