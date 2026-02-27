include "root" {
  path = find_in_parent_folders("root.hcl")
}

dependency "bootstrap" {
  config_path = "../bootstrap"

  mock_outputs = {
    github_actions_role_arn = "arn:aws:iam::123456789012:role/mock"
    github_oidc_provider_arn = "arn:aws:iam::123456789012:oidc-provider/mock"
  }
  mock_outputs_allowed_terraform_commands = ["plan", "validate", "destroy"]
}