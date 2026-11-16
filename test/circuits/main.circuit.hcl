# A circuit with no hosts, so the plan-apply workflow's test plans and
# applies without logging in anywhere.
circuit "noop" {
  hosts = {}

  ssh {
    user = "root"
  }

  step "hello" {
    command {
      command = "true"
    }
  }
}
