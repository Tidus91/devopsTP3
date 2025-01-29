provider "google" {
  project = var.project_id
  region  = var.region
}

variable "project_id" {}
variable "region" {
  default = "us-central1"
}

resource "google_artifact_registry_repository" "repo" {
  name     = "my-repo"
  format   = "DOCKER"
  location = var.region
}



resource "google_cloud_run_service_iam_policy" "allow_all" {
  location = google_cloud_run_service.node_app.location
  service  = google_cloud_run_service.node_app.name
  policy_data = <<EOF
{
  "bindings": [
    {
      "role": "roles/run.invoker",
      "members": ["allUsers"]
    }
  ]
}
EOF
}
