# canvas-prerequisites

This repository provides installation of prerequisites for the TM Forum ODA Canvas Reference Implementation ([oda-canvas](https://github.com/tmforum-oda/oda-canvas)). It uses an overarching Helm chart-of-charts to deploy all required components.

## Features

- Apache 2.0 licensed
- Installs all prerequisites via Helm
- Includes sub-charts (first: Keycloak)
- Extensible for future prerequisites

## Structure

- `charts/`: Helm chart-of-charts
- `identity/keycloak/`: Keycloak dependent chart
- `LICENSE`: Apache 2.0 license
- `.gitignore`: Ignore unnecessary files
- `.github/copilot-instructions.md`: Instructions for optimising GitHub Copilot usage

## Prerequisites

- You have [Helm](https://helm.sh/) installed and available in your PATH.
- You have [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured for your cluster.
- You have access to a running Kubernetes cluster.

## Usage

1. Clone this repo
2. Install Istio:
   ```sh
   helm repo add istio https://istio-release.storage.googleapis.com/charts
   helm repo update
   helm install istio-base istio/base
   helm install istiod istio/istiod
   # See Istio documentation for further steps and configuration
   ```
3. Review and customise values in `charts/values.yaml` as needed.
4. Deploy the chart-of-charts:
   ```sh
   helm install prerequisites ./charts
   ```
5. Configure dependent charts as needed

> **Note:** This repository includes a `Taskfile.yaml` with example automation steps for installing prerequisites.

## Configuration Values

> **Note:** This table lists the main values exposed for customisation in the chart-of-charts. For a full list of configurable values for sub-charts and dependencies (such as Keycloak), refer to the `values.yaml` file in each dependent chart directory (e.g. `identity/keycloak/values.yaml`).

| Key                          | Default Value | Source                | Type    | Purpose                                      |
|------------------------------|--------------|-----------------------|---------|----------------------------------------------|
| `keycloak.enabled`           | `true`       | chart-of-charts       | boolean | Enable/disable Keycloak deployment           |
| `keycloak.username`          | `""`         | Keycloak sub-chart    | string  | Keycloak admin username (uses chart default) |
| `keycloak.password`          | `""`         | Keycloak sub-chart    | string  | Keycloak admin password (uses chart default) |
| `keycloak.postgres.username` | `""`         | Keycloak sub-chart    | string  | Postgres DB username for Keycloak (default)  |
| `keycloak.postgres.password` | `""`         | Keycloak sub-chart    | string  | Postgres DB password for Keycloak (default)  |

## Contributing

See `COPILOT.md` for guidance on using Copilot and contributing.

## License

Apache 2.0. See `LICENSE` for details.
