# CircleCI Configuration

This directory contains the CircleCI configuration for automated releases of hellbun.

## Configuration File

- `config.yml` - Main CircleCI pipeline configuration

## How it Works

The CircleCI workflow triggers only when a version tag (matching `v*`) is pushed to the repository:

1. **Checkout**: Fetches the repository code and all Git tags
2. **Install Bun**: Downloads and installs the latest Bun runtime
3. **Install Dependencies**: Runs `bun install` to get project dependencies
4. **Install GoReleaser**: Downloads GoReleaser v2.6.1
5. **Run GoReleaser**: Executes the release process which:
   - Builds binaries for all platforms
   - Creates archives and checksums
   - Generates Homebrew formula
   - Generates Nix package
   - Creates GitHub release
   - Publishes to distribution channels

## Setup Instructions

### 1. Connect Repository to CircleCI

1. Go to https://circleci.com/
2. Sign in with your GitHub account
3. Click "Projects" in the sidebar
4. Find your repository and click "Set Up Project"
5. CircleCI will detect the `.circleci/config.yml` automatically

### 2. Add Environment Variables

Go to Project Settings → Environment Variables and add:

| Variable | Description | Required |
|----------|-------------|----------|
| `GITHUB_TOKEN` | GitHub Personal Access Token with `repo` scope | Yes |
| `HOMEBREW_TAP_TOKEN` | Token for updating Homebrew tap (can be same as GITHUB_TOKEN) | Optional |

#### Creating a GitHub Token

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Give it a descriptive name (e.g., "hellbun-circleci")
4. Select scopes:
   - ✅ `repo` (Full control of private repositories)
   - ✅ `write:packages` (optional, for GitHub Packages)
5. Click "Generate token"
6. Copy the token immediately (you won't see it again!)
7. Add it to CircleCI as `GITHUB_TOKEN`

### 3. Trigger a Release

```bash
# Tag your release
git tag -a v1.0.0 -m "First release"

# Push the tag (this triggers CircleCI)
git push origin v1.0.0

# View the build at https://app.circleci.com/pipelines/github/z00b/hello-bun
```

## Workflow Filters

The workflow is configured to:
- ✅ Run on all tags matching `v*` (e.g., v1.0.0, v2.1.3-beta)
- ❌ Ignore all branch pushes
- ❌ Ignore non-version tags

This ensures releases only happen when you explicitly create a version tag.

## Docker Image

The workflow uses `cimg/base:stable` which is CircleCI's base Ubuntu image. This provides:
- Ubuntu LTS
- Essential build tools
- Git
- curl/wget

We install Bun and GoReleaser during the workflow.

## Resource Class

The workflow uses `medium` resource class which provides:
- 2 vCPUs
- 4GB RAM

This is sufficient for building the Bun binaries. Adjust if needed for larger projects.

## Troubleshooting

### Build fails with "permission denied"
- Check that your `GITHUB_TOKEN` has the `repo` scope
- Verify the token is still valid (not expired or revoked)

### Bun installation fails
- Check CircleCI's network connectivity
- Verify the Bun install script URL is still valid

### GoReleaser fails
- Ensure your `.goreleaser.yaml` is valid: `goreleaser check`
- Verify all required files exist (LICENSE, README.md)
- Check that the tag follows semantic versioning

### Homebrew/Nix publishing fails
- Verify the target repositories exist
- Check that tokens have write permissions
- Ensure repository names match the configuration

## Local Testing

Test the GoReleaser configuration locally before pushing tags:

```bash
# Snapshot build (no publishing)
goreleaser release --snapshot --clean --skip=publish

# Validate configuration
goreleaser check
```

## Customization

### Change GoReleaser Version

Edit the GoReleaser download URL in `config.yml`:

```yaml
curl -sL https://github.com/goreleaser/goreleaser/releases/download/v2.6.1/goreleaser_Linux_x86_64.tar.gz
#                                                                       ^^^^^^
#                                                            Change this version
```

### Change Resource Class

If builds are slow or run out of memory, upgrade to a larger resource class:

```yaml
resource_class: large  # 4 vCPUs, 8GB RAM
# or
resource_class: xlarge  # 8 vCPUs, 16GB RAM
```

See: https://circleci.com/docs/configuration-reference/#resourceclass

### Add More Jobs

You can add additional jobs for testing, linting, etc.:

```yaml
workflows:
  version: 2
  test-and-release:
    jobs:
      - test  # Add a test job
      - release:
          requires:
            - test
          filters:
            tags:
              only: /^v.*/
            branches:
              ignore: /.*/
```
