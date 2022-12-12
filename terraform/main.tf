provider "google" {
  credentials = file(var.credentials)
  project     = var.project
  region      = var.region
}

provider "random" {
}

resource "random_id" "nagaexchange" {
  byte_length = 2
}

resource "google_compute_instance" "nagaexchange" {
  name         = "${var.instance_name}-${random_id.nagaexchange.hex}"
  machine_type = var.machine_type
  zone         = var.zone

  allow_stopping_for_update = true

  boot_disk {
    initialize_params {
      image = var.image
      type  = "pd-ssd"
      size  = 120
    }
  }

  network_interface {
    network = google_compute_network.nagaexchange.name

    access_config {
      nat_ip = google_compute_address.nagaexchange.address
    }
  }

  service_account {
    scopes = ["storage-ro"]
  }

  tags = ["allow-webhook"]

  metadata = {
    sshKeys = "${var.ssh_user}:${file(var.ssh_public_key)}"
  }

  provisioner "local-exec" {
    command = "mkdir -p /tmp/upload && rsync -rv --exclude=terraform ../ /tmp/upload/"
  }

  provisioner "remote-exec" {
    inline = [
      "mkdir -p /home/${var.ssh_user}/nagaexchange",
    ]

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "file" {
    source      = "/tmp/upload/"
    destination = "/home/${var.ssh_user}/nagaexchange"

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    script = "../bin/install.sh"

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    script = "../bin/start.sh"

    connection {
      host        = self.network_interface[0].access_config[0].nat_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }
}

resource "google_compute_firewall" "nagaexchange" {
  name    = "nagaexchange-firewall-${random_id.nagaexchange.hex}"
  network = google_compute_network.nagaexchange.name

  allow {
    protocol = "tcp"
    ports    = ["80", "8080", "1337", "443", "22"]
  }

  source_ranges = ["0.0.0.0/0"]

  target_tags = ["allow-webhook"]
}

resource "google_compute_address" "nagaexchange" {
  name = "nagaexchange-ip-${random_id.nagaexchange.hex}"
}

resource "google_compute_network" "nagaexchange" {
  name = "nagaexchange-network-${random_id.nagaexchange.hex}"
}

