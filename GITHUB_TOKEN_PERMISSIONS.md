# GitHub Token Permissions for GoReleaser

## Required Tokens

You'll need either **one token** with broad permissions or **separate tokens** for different purposes.

## Option 1: Single Token (Recommended for simplicity)

### Fine-Grained Personal Access Token (Recommended)

Create at: https://github.com/settings/tokens?type=beta

**Repository Access:**
- Select "All repositories" or specific repositories:
  - `z00b/hello-bun` (the main project)
  - `z00b/homebrew-tap` (if using Homebrew)
  - `z00b/nur-packages` (if using Nix)

**Permissions:**

| Permission | Access Level | Why Needed |
|------------|-------------|------------|
| **Contents** | Read and write | Create releases, upload assets, push to tap/nur repos |
| **Metadata** | Read-only | Required by GitHub (automatically selected) |
| **Pull requests** | Read and write | Optional: if you want GoReleaser to create/update PRs |

### Classic Personal Access Token

Create at: https://github.com/settings/tokens

**Scopes needed:**

| Scope | Why Needed |
|-------|------------|
| ✅ `repo` (Full control of private repositories) | **Required**: Create releases, upload assets, push to repositories |
| ✅ `write:packages` | Optional: If publishing to GitHub Packages |
| ✅ `workflow` | Optional: If GoReleaser needs to trigger GitHub Actions |

**The `repo` scope includes:**
- `repo:status` - Commit status
- `repo_deployment` - Deployment status
- `public_repo` - Public repositories
- `repo:invite` - Repository invitations
- `security_events` - Security events

## Option 2: Separate Tokens (Most Secure)

### Token 1: Main Repository (`GITHUB_TOKEN`)

For creating releases in `z00b/hello-bun`:

**Fine-Grained Token:**
- Repository access: `z00b/hello-bun` only
- Permissions: Contents (Read and write)

**Classic Token:**
- Scope: `public_repo` (if public) or `repo` (if private)

### Token 2: Homebrew Tap (`HOMEBREW_TAP_TOKEN`)

For pushing formula to `z00b/homebrew-tap`:

**Fine-Grained Token:**
- Repository access: `z00b/homebrew-tap` only
- Permissions: Contents (Read and write)

**Classic Token:**
- Scope: `public_repo`

### Token 3: NUR Packages (can use `GITHUB_TOKEN` or separate)

For pushing to `z00b/nur-packages`:

**Fine-Grained Token:**
- Repository access: `z00b/nur-packages` only
- Permissions: Contents (Read and write)

## How GoReleaser Uses the Tokens

### `GITHUB_TOKEN` Environment Variable

Used by GoReleaser for:
1. ✅ Creating GitHub releases
2. ✅ Uploading release assets (binaries, archives, checksums)
3. ✅ Generating release notes
4. ✅ Pushing to Homebrew tap (if no separate token)
5. ✅ Pushing to NUR repository (if no separate token)

### `HOMEBREW_TAP_GITHUB_TOKEN` (Optional)

If provided, GoReleaser uses this specifically for Homebrew operations.
If not provided, it falls back to `GITHUB_TOKEN`.

## Creating a Fine-Grained Token (Recommended)

Fine-grained tokens are more secure because you can:
- Limit access to specific repositories
- Set granular permissions
- Set expiration dates

### Steps:

1. Go to https://github.com/settings/tokens?type=beta
2. Click "Generate new token"
3. Fill in:
   - **Token name**: `hellbun-goreleaser`
   - **Expiration**: Choose (90 days, 1 year, or custom)
   - **Repository access**: Select repositories or "All repositories"
   - **Permissions**:
     - Repository permissions → Contents → **Read and write**
4. Click "Generate token"
5. **Copy immediately** (you won't see it again!)

## Creating a Classic Token

Classic tokens have broader permissions but are simpler:

1. Go to https://github.com/settings/tokens
2. Click "Generate new token (classic)"
3. Fill in:
   - **Note**: `hellbun-goreleaser`
   - **Expiration**: Choose (30, 60, 90 days, 1 year, or no expiration)
   - **Select scopes**:
     - ✅ `repo` (Full control)
4. Click "Generate token"
5. **Copy immediately**

## Setting Tokens in CircleCI

### Via Web UI:

1. Go to https://app.circleci.com/
2. Navigate to your project
3. Click "Project Settings"
4. Click "Environment Variables"
5. Click "Add Environment Variable"
6. Add:
   - Name: `GITHUB_TOKEN`
   - Value: `ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx`

### Via CircleCI CLI:

```bash
circleci env create GITHUB_TOKEN ghp_xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
```

## Security Best Practices

1. ✅ **Use fine-grained tokens** when possible
2. ✅ **Set expiration dates** (rotate tokens regularly)
3. ✅ **Limit to specific repositories** (don't use "All repositories" unless needed)
4. ✅ **Use separate tokens** for different purposes when possible
5. ✅ **Store in CI/CD secrets** (never commit to repository)
6. ✅ **Revoke immediately** if compromised
7. ✅ **Audit token usage** regularly in GitHub settings

## Token Permissions Summary

### Minimum Required (Single Token):

```
Fine-Grained Token:
  - Repositories: hello-bun, homebrew-tap, nur-packages
  - Permissions: Contents (Read and write)

Classic Token:
  - Scope: repo
```

### Recommended (Separate Tokens):

```
GITHUB_TOKEN (Fine-Grained):
  - Repository: hello-bun only
  - Permissions: Contents (Read and write)

HOMEBREW_TAP_TOKEN (Fine-Grained):
  - Repository: homebrew-tap only
  - Permissions: Contents (Read and write)
```

## Verification

To verify your token has the right permissions:

```bash
# Test with curl
curl -H "Authorization: token YOUR_TOKEN" \
     https://api.github.com/repos/z00b/hello-bun

# Should return repository information without errors
```

## Troubleshooting

### Error: "Resource not accessible by integration"
- Token doesn't have `Contents: Write` permission
- Token doesn't have access to the repository
- Token has expired

### Error: "Bad credentials"
- Token is invalid or revoked
- Token wasn't copied correctly (check for extra spaces)

### Error: "Not Found"
- Repository doesn't exist
- Token doesn't have access to the repository
- Repository name is incorrect in configuration

## Token Rotation

It's good practice to rotate tokens periodically:

1. Create a new token with the same permissions
2. Update the token in CircleCI
3. Test with a snapshot build
4. Revoke the old token once confirmed working
