# CircleCI Configuration

This directory contains the CircleCI configuration for automated releases of hellbun.

## Configuration File

- `config.yml` - Main CircleCI pipeline configuration

## Context Usage

The workflow uses the **`z00b-releaser`** context, which provides:
- Centralized management of release credentials
- Reusable across multiple projects in the `z00b` organization
- Security group restrictions (optional)
- Easy token rotation without updating individual projects

## How it Works

The CircleCI workflow triggers only when a version tag (matching `v*`) is pushed to the repository:

1. **Checkout**: Fetches the repository code and all Git tags
2. **Install Bun**: Downloads and installs the latest Bun runtime
3. **Install Dependencies**: Runs `bun install` to get project dependencies
4. **Install Flox**: Installs Flox (provides Nix tools)
5. **Install GoReleaser**: Downloads GoReleaser v2.6.1
6. **Run GoReleaser (Pass 1)**: Executes the main release (`.goreleaser.yaml`):
   - Builds binaries for all platforms
   - Creates archives and checksums
   - Generates Homebrew formula
   - Creates GitHub release with all assets
   - Publishes Homebrew formula to tap
7. **Wait**: Sleeps for 15 seconds to allow GitHub to process the release
8. **Run GoReleaser (Pass 2)**: Executes Nix-only config (`.goreleaser.nix.yaml`):
   - Fetches release assets from GitHub to calculate proper SHA256 hashes
   - Generates Nix package with correct hashes
   - Publishes to NUR repository
9. **Add flake.nix**: Copies flake.nix to NUR repository (first time only)

## Setup Instructions

### 1. Connect Repository to CircleCI

1. Go to https://circleci.com/
2. Sign in with your GitHub account
3. Click "Projects" in the sidebar
4. Find your repository and click "Set Up Project"
5. CircleCI will detect the `.circleci/config.yml` automatically

### 2. Set Up Context with Environment Variables

This project uses the **`z00b-releaser`** context to manage environment variables across multiple projects.

#### Create the Context:

1. Go to https://app.circleci.com/
2. Click "Organization Settings" (in the sidebar)
3. Click "Contexts"
4. Click "Create Context"
5. Name it: `z00b-releaser`
6. Click "Create Context"

#### Add Environment Variables to Context:

1. Click on the `z00b-releaser` context
2. Click "Add Environment Variable"
3. Add the following variables:

| Variable | Description | Required |
|----------|-------------|----------|
| `GITHUB_TOKEN` | GitHub Personal Access Token with `repo` scope | Yes |
| `HOMEBREW_TAP_TOKEN` | Token for updating Homebrew tap (can be same as GITHUB_TOKEN) | Optional |

#### Context Security:

Contexts can be restricted to specific security groups. To add restrictions:
1. In the context page, click "Add Security Group"
2. Choose which teams/groups can use this context
3. This prevents unauthorized projects from accessing your tokens

#### Creating a GitHub Token

**See [GITHUB_TOKEN_PERMISSIONS.md](../GITHUB_TOKEN_PERMISSIONS.md) for detailed permission requirements.**

Quick guide:

1. Go to https://github.com/settings/tokens?type=beta (Fine-grained) or https://github.com/settings/tokens (Classic)
2. Click "Generate new token"
3. Give it a descriptive name (e.g., "hellbun-circleci")
4. **Fine-grained token (Recommended):**
   - Repository access: Select `hello-bun`, `homebrew-tap`, `nur-packages`
   - Permissions: Contents → Read and write
5. **Classic token:**
   - Scopes: `repo` (Full control)
6. Click "Generate token"
7. Copy the token immediately (you won't see it again!)
8. Add it to CircleCI context as `GITHUB_TOKEN`

#### Alternative: Using CircleCI CLI

You can also manage contexts via the CircleCI CLI:

```bash
# Install CircleCI CLI first:
# https://circleci.com/docs/local-cli/

# Create context (if not exists)
circleci context create github z00b-releaser

# Add environment variables to context
circleci context store-secret github z00b-releaser GITHUB_TOKEN
# Enter token when prompted

# Optional: Add Homebrew tap token
circleci context store-secret github z00b-releaser HOMEBREW_TAP_TOKEN
# Enter token when prompted

# List contexts
circleci context list github z00b

# List environment variables in context
circleci context show github z00b z00b-releaser
```

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

We install the following tools during the workflow:
- **Bun**: JavaScript runtime for building the application
- **Nix**: Package manager (provides `nix-prefetch-url` for generating Nix package hashes)
- **GoReleaser**: Release automation tool

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

### Nix installation fails
- Nix installation may take a few minutes (it's normal)
- Check if the Nix install script URL is accessible
- Verify CircleCI has sufficient disk space

### "nix-prefetch-url is not available" error
- This means Nix wasn't installed properly or isn't in PATH
- The workflow now installs Nix before running GoReleaser
- Verify the `~/.nixenv` file is being sourced correctly

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
