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
| `version` | `latest` | The release to install, such as `0.17.0` or `v0.17.0`. Pin it, so a new release doesn't change your CI on a day you didn't choose. |
| `github-token` | `${{ github.token }}` | Used only to look up the latest release, so the lookup isn't rate-limited. |

## Outputs

| Name | What it holds |
| --- | --- |
| `version` | The version installed, without the `v`. |

## What it doesn't do yet

- There's no wrapper that hands later steps the plan's output and exit code, as `hashicorp/setup-terraform` does. `conn3x plan -detailed-exitcode` gives you the exit code today.
- It caches in the runner's tool cache, which lasts for one job on GitHub-hosted runners and across jobs on self-hosted ones. It doesn't use `actions/cache`.
- It checks the checksum, not the cosign signature on `checksums.txt` that vouches for it.

## License

[MPL-2.0](LICENSE), like Conn3x.
