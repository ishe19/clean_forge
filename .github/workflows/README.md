# CI/CD Workflows

This directory contains GitHub Actions workflows for automated CI/CD processes.

## Workflows

### Publish to pub.dev

**File**: `publish.yml`

**Triggers**: When a release is published on GitHub

**What it does**:
1. Checks out the code
2. Sets up Dart SDK (stable)
3. Installs dependencies
4. Runs tests
5. Checks code formatting
6. Analyzes code for issues
7. Publishes the package to pub.dev

## Required GitHub Secrets

To enable automatic publishing to pub.dev, you need to configure the following secrets in your GitHub repository:

### PUB_DEV_PUBLISH_ACCESS_TOKEN
- **How to get it**: Go to https://pub.dev → Account → Authorized publishing → Create a new token
- **Purpose**: Access token for pub.dev API

### PUB_DEV_PUBLISH_REFRESH_TOKEN
- **How to get it**: Same as above, when creating the token you'll get both access and refresh tokens
- **Purpose**: Refresh token for pub.dev API (used for long-term authentication)

### Setting up Secrets
1. Go to your GitHub repository
2. Navigate to Settings → Secrets and variables → Actions
3. Click "New repository secret"
4. Add each secret with the exact names above

## Usage

1. Create a new release on GitHub (tag it with a version like `v1.0.0`)
2. The workflow will automatically run and publish to pub.dev
3. Check the Actions tab to monitor the progress

## Notes

- The workflow only runs on published releases, not on pre-releases or drafts
- All tests must pass before publishing
- Code must be properly formatted and pass analysis
- Make sure your `pubspec.yaml` has the correct version before creating a release