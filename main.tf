terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region
}

# 🔹 Activer les APIs nécessaires
resource "google_project_service" "enable_services" {
  for_each = toset([
    "run.googleapis.com",             # Cloud Run
    "artifactregistry.googleapis.com", # Artifact Registry
    "cloudbuild.googleapis.com",       # Cloud Build
  ])
  service = each.key
}

# 🔹 Créer un repository Artifact Registry pour stocker l’image Docker
resource "google_artifact_registry_repository" "node_repo" {
  location      = var.region
  repository_id = "node-app-repo"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

# 🔹 (Bonus) Déployer l’application sur Cloud Run
resource "google_cloud_run_service" "node_app" {
  name     = "node-app"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/node-app-repo/node-app:latest"
        ports {
          container_port = 80
        }
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }
}

# 🔹 Donner les permissions à Cloud Build pour déployer sur Cloud Run
resource "google_project_iam_member" "cloud_build_run" {
  project = var.project_id
  role    = "roles/run.admin"
  member  = "serviceAccount:${var.project_id}@cloudbuild.gserviceaccount.com"
}
