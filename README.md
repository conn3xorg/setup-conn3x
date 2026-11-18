# setup-conn3x

Install [Conn3x](https://github.com/conn3xorg/conn3x) on a GitHub Actions runner, so a workflow can run `conn3x plan`, `conn3x test` or `conn3x drift` without writing its own download step.

```yaml
steps:
  - uses: actions/checkout@v5
  - uses: conn3xorg/setup-conn3x@v1
  - run: conn3x init && conn3x plan
```

It downloads the release archive for the runner, checks it against the release's `checksums.txt`, and puts `conn3x` on `PATH`. It works on Linux and macOS runners and on Windows, amd64 and arm64.

## Inputs

| Name | Default | What it does |
| --- | --- | --- |
| `version` | `latest` | The release to install, such as `0.25.0` or `v0.25.0`. Pin it, so a new release doesn't change your CI on a day you didn't choose. |
| `github-token` | `${{ github.token }}` | Used only to look up the latest release, so the lookup isn't rate-limited. |

## Outputs

| Name | What it holds |
| --- | --- |
| `version` | The version installed, without the `v`. |

## Plan on pull requests, apply on merge

Most teams want what Atlantis gives Terraform: every pull request shows what it will change, and merging it makes the change. This repository has a reusable workflow for that.

```yaml
on:
  pull_request:
  push:
    branches: [main]

jobs:
  conn3x:
    uses: conn3xorg/setup-conn3x/.github/workflows/plan-apply.yml@v1
    permissions:
      contents: read
      pull-requests: write
    with:
      working-directory: circuits
      version: 0.25.0
    secrets:
      ssh-private-key: ${{ secrets.CONN3X_SSH_KEY }}
      known-hosts: ${{ secrets.CONN3X_KNOWN_HOSTS }}
```

On a pull request it runs `conn3x plan` and keeps one comment up to date with the result, host steps included. A newer push replaces a plan that's still running. On a push to the default branch it runs `conn3x apply`, one at a time for each directory, and comments the output on the pull request that was merged. Set `apply: false` to plan there instead, while you build trust in it.

A few things to know before you turn it on:

- **State has to live somewhere shared.** Each run starts on a clean runner, so the circuits need a remote backend. Local state is gone when the job ends.
- **What's applied is a fresh plan.** The apply runs after the merge, so if a host changed since the pull request's plan, the apply does what's needed now, not exactly what the comment showed.
- **The key goes into `ssh-agent`.** Leave `private_key_file` unset in your `ssh` blocks and Conn3x uses the agent. `known-hosts` is appended to `~/.ssh/known_hosts`, so every host's key is still checked.
- **Pull requests from forks get no secrets.** Their plan runs without a key and says so; push the branch to the repository to plan it for real. Don't call this workflow from `pull_request_target`, which would run a fork's circuits with your secrets.
- **The plan comment is as public as the repository.** Sensitive values show as `(sensitive value)`, but host names and file paths are there for anyone who can read the pull request.

## What it doesn't do yet

- There's no wrapper that hands later steps the plan's output and exit code, as `hashicorp/setup-terraform` does. `conn3x plan -detailed-exitcode` gives you the exit code today.
- It caches in the runner's tool cache, which lasts for one job on GitHub-hosted runners and across jobs on self-hosted ones. It doesn't use `actions/cache`.
- It checks the checksum, not the cosign signature on `checksums.txt` that vouches for it.

## License

[MPL-2.0](LICENSE), like Conn3x.
