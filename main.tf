provider "google" {
  project = var.project_id
  region  = var.region
}

resource "google_project_service" "run" {
  service = "run.googleapis.com"
}

resource "google_project_service" "artifactregistry" {
  service = "artifactregistry.googleapis.com"
}

resource "google_artifact_registry_repository" "my-repo" {
  location      = var.region
  repository_id = "my-nodejs-repo"
  format        = "DOCKER"

  depends_on = [google_project_service.artifactregistry]
}

resource "google_cloud_run_service" "my-service" {
  name     = "my-nodejs-app"
  location = var.region

  template {
    spec {
      containers {
        image = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.my-repo.repository_id}/my-nodejs-app:latest"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  depends_on = [google_project_service.run]
}

output "cloud_run_url" {
  value = google_cloud_run_service.my-service.status[0].url
}
