resource "yandex_compute_disk" "boot-disk" {
  count    = 2
  name     = "boot-disk-${count.index}"
  size     = "20"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  image_id = var.os_image
}

resource "yandex_vpc_network" "default" {
  name = "project"
}

resource "yandex_vpc_subnet" "web" {
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.default.id
  v4_cidr_blocks = ["192.168.0.0/24"]
}

resource "yandex_compute_instance" "vm" {
  count       = 2
  name        = "web-${count.index}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 5
    cores         = 2
    memory        = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[count.index].id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.web.id
    nat       = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.yc_user}:${var.ssh_public_key}"
  }

  connection {
    type        = "ssh"
    user        = var.yc_user
    private_key = var.ssh_private_key_path
    host        = self.network_interface[0].nat_ip_address
  }
}


resource "yandex_lb_network_load_balancer" "lb" {
  name = "project-lb"

  listener {
    name        = "http"
    port        = 80
    target_port = 80
    external_address_spec {}
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
      interval            = 2
      timeout             = 1
      unhealthy_threshold = 3
      healthy_threshold   = 2
    }
  }
}

resource "yandex_lb_target_group" "web" {
  name = "project-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.vm[*].network_interface.0.ip_address
    content {
      address   = target.value
      subnet_id = yandex_vpc_subnet.web.id
    }
  }
}

resource "yandex_mdb_postgresql_cluster" "dbcluster" {
  name        = "project-cluster"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.default.id

  config {
    version = 17
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 10
    }
    postgresql_config = {
      max_connections = 100
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.web.id
  }
}

resource "yandex_mdb_postgresql_user" "dbuser" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_user
  password   = var.db_password
  depends_on = [yandex_mdb_postgresql_cluster.dbcluster]
}

resource "yandex_mdb_postgresql_database" "db" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_name
  owner      = yandex_mdb_postgresql_user.dbuser.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  depends_on = [yandex_mdb_postgresql_cluster.dbcluster]
}

output "ansible_inventory" {
  value = <<-DOC
    [webservers]
    %{~for i in yandex_compute_instance.vm~}
    ${i.name} ansible_host=${i.network_interface[0].nat_ip_address}
    %{~endfor~}
    DOC
}

output "database_credentials" {
  value = <<-DOC
    db_host: ${yandex_mdb_postgresql_cluster.dbcluster.host.0.fqdn}
    DOC
}

resource "yandex_dns_zone" "default" {
  name   = "mur-devops"
  zone   = var.domain_name
  public = true
}

resource "yandex_dns_recordset" "a" {
  zone_id = yandex_dns_zone.default.id
  name    = "@"
  type    = "A"
  ttl     = 600
  data = [for listener in yandex_lb_network_load_balancer.lb.listener :
    listener.external_address_spec[*].address
  if listener.name == "http"][0]
}
resource "datadog_monitor" "host_is_up" {
  name               = "host is up"
  type               = "service check"
  message            = "Monitor triggered"
  escalation_message = "Escalation message"

  query = "\"http.can_connect\".over(\"*\").by(\"url\").last(4).count_by_status()"

  monitor_thresholds {
    ok       = 0
    warning  = 1
    critical = 2
  }

  notify_no_data    = true
  renotify_interval = 60
  notify_audit = true
  timeout_h    = 1
}
