workflow "Cirrus CI email" {
  on = "check_suite"
  resolves = ["Send email"]
}

action "Send email" {
  uses = "docker://fertapric/elixir-ci-email:latest"
  secrets = ["GITHUB_TOKEN", "MAIL_FROM", "MAIL_HOST", "MAIL_USERNAME", "MAIL_PASSWORD"]
  env = {
    APP_NAME = "Cirrus CI"
  }
}
