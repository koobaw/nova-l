# Terraform configuration to set up providers by version.
terraform {
  required_providers {
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "~> 4.0"
    }
  }
}

# Configures the provider to use the resource block's specified project for quota checks.
provider "google-beta" {
  user_project_override = true
}

# Configures the provider to not use the resource block's specified project for quota checks.
# This provider should only be used during project creation and initializing services.
provider "google-beta" {
  alias = "no_user_project_override"
  user_project_override = false
}

# Creates a new Google Cloud project.
# resource "google_project" "default" {
#   provider   = google-beta.no_user_project_override

#   name       = "Project Display Name"
#   project_id = "project-id-for-new-project"
#   # Required for any service that requires the Blaze pricing plan
#   # (like Firebase Authentication with GCIP)
#   billing_account = "000000-000000-000000"

#   # Required for the project to display in any list of Firebase projects.
#   labels = {
#     "firebase" = "enabled"
#   }
# }

# Enables required APIs.
resource "google_project_service" "default" {
  provider = google-beta.no_user_project_override
  project  = var.project_id
  for_each = toset([
    "cloudbilling.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "firebase.googleapis.com",
    # Enabling the ServiceUsage API allows the new project to be quota checked from now on.
    "serviceusage.googleapis.com",
  ])
  service = each.key

  # Don't disable the service if the resource block is removed by accident.
  disable_on_destroy = false
}

# Enables Firebase services for the new project created above.
resource "google_firebase_project" "default" {
  provider = google-beta
  project  = var.project_id
}

# Creates a Firebase Android App in the new project created above.
resource "google_firebase_android_app" "default" {
  provider = google-beta
  project      = var.project_id
  display_name = "My Awesome Android app"
  package_name = "awesome.nova-kk.name"
}
