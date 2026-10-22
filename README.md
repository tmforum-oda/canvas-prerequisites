# canvas-prerequisites

This repository provides installation of prerequisites for the TM Forum ODA Canvas Reference Implementation ([oda-canvas](https://github.com/tmforum-oda/oda-canvas)). It uses an overarching Helm chart-of-charts to deploy all required components.

## Features

- Apache 2.0 licensed
- Installs all prerequisites via Helm
- Includes sub-charts (first: Keycloak)
- Extensible for future prerequisites
- Automation tasks managed via `Taskfile.yaml` (see below)

## Structure

- `charts/`: Helm chart-of-charts and values for prerequisites
- `identity/keycloak/`: Keycloak dependent chart and configuration
- `tests/`: BDD tests and Cucumber step definitions
- `Taskfile.yaml`: Automation for testing and linting
- `.github/agents/`: Agent definitions for documentation and automation
- `.github/copilot-instructions.md`: AI agent usage instructions
- `CONTRIBUTING.md`: Contribution guidelines
- `LICENSE`: Apache 2.0 license
- `.gitignore`: Ignore unnecessary files

## Automation with Taskfile

Automation tasks are managed using `Taskfile.yaml`. Key tasks include:
- `install-all`: Install all prerequisites (Istio + Keycloak) with a single command
- `add-istio-repo`: Add the Istio Helm repository
- `install-istio`: Install Istio base, istiod (to `istio-system`), and gateway (to `istio-ingress`)
- `install-prerequisites-chart`: Install Keycloak and Postgres
- `test`: Run BDD tests (`cd tests && npm install && npm test`)
- `lint`: Lint YAML files (`yamllint charts/ identity/`)

> Tip: Run `task install-all` for a complete one-command installation of all prerequisites.

## Testing

- BDD tests are in `tests/` and use Cucumber.js.
- See `tests/README.md` for setup and manual test execution instructions.

## Prerequisites

- You have [Helm](https://helm.sh/) installed and available in your PATH.
- You have [kubectl](https://kubernetes.io/docs/tasks/tools/) installed and configured for your cluster.
- You have access to a running Kubernetes cluster.

## Usage

1. Clone this repo
2. Review and customise values in `charts/values.yaml` as needed. For example:
   - To deploy Keycloak to a custom namespace (default is `keycloak`):
     ```yaml
     keycloak:
       namespace: my-custom-namespace
       global:
         keycloakNamespace: my-custom-namespace  # Must match keycloak.namespace for Postgres subchart
     ```
   - Or override via command line (note: both values must be set for Postgres to use the custom namespace):
     ```sh
     helm install prerequisites ./charts \
       --set keycloak.namespace=my-custom-namespace \
       --set keycloak.global.keycloakNamespace=my-custom-namespace
     ```
3. Install all prerequisites with a single command:
   ```sh
   task install-all
   ```
   This will:
   - Add the Istio Helm repository
   - Install Istio base and istiod to `istio-system` namespace
   - Install Istio gateway to `istio-ingress` namespace
   - Install Keycloak and Postgres to `keycloak` namespace (or custom namespace)
   
   Or, if you prefer to run commands manually:
   ```sh
   helm repo add istio https://blob.istio.io/istio-release/charts
   helm repo update
   kubectl create namespace istio-system
   helm install istio-base istio/base -n istio-system --wait
   helm install istiod istio/istiod -n istio-system --wait
   helm install istio-gateway istio/gateway -n istio-ingress --create-namespace --wait
   helm dependency update ./charts
   helm install prerequisites ./charts
   ```
   
4. Verify the installation:
   ```sh
   kubectl get pods -n istio-system     # Check Istio base and istiod
   kubectl get pods -n istio-ingress    # Check Istio gateway
   kubectl get pods -n keycloak         # Check Keycloak and Postgres
   ```

> **Note:** Istio base and istiod are installed to `istio-system` namespace. Istio gateway is installed to `istio-ingress` namespace. Canvas prerequisites (Keycloak) are installed via the Helm chart-of-charts to the `keycloak` namespace.

## Configuration Values

The following table lists the main values exposed for customisation in the chart-of-charts. For a full list of configurable values for sub-charts and dependencies (such as Keycloak), refer to the `values.yaml` file in each dependent chart directory (e.g., `identity/keycloak/values.yaml`).

| Key                          | Default Value | Source                | Type    | Purpose                                      |
|------------------------------|--------------|-----------------------|---------|----------------------------------------------|
| `namespaces`                 | `[keycloak]` | chart-of-charts       | list    | Kubernetes namespaces to create for Canvas prerequisites |
| `keycloak.enabled`           | `true`       | chart-of-charts       | boolean | Enable/disable Keycloak deployment           |
| `keycloak.namespace`         | `keycloak`   | Keycloak sub-chart    | string  | Kubernetes namespace for Keycloak and Postgres |
| `keycloak.username`          | `""`         | Keycloak sub-chart    | string  | Keycloak admin username (uses chart default) |
| `keycloak.password`          | `""`         | Keycloak sub-chart    | string  | Keycloak admin password (uses chart default) |
| `keycloak.postgres.username` | `""`         | Keycloak sub-chart    | string  | Postgres DB username for Keycloak (default)  |
| `keycloak.postgres.password` | `""`         | Keycloak sub-chart    | string  | Postgres DB password for Keycloak (default)  |

**Namespace Management:**
- **Canvas Prerequisites Namespaces**: Defined in `namespaces` list (e.g., `keycloak`). These are created automatically by the Helm chart-of-charts when you run `helm install prerequisites ./charts`.
- **Istio Infrastructure Namespaces**: Created by Taskfile tasks:
  - `istio-system`: Created by `task install-istio` (base, istiod components)
  - `istio-ingress`: Created by `task install-istio` (gateway component)
- To add new prerequisite namespaces (e.g., observability, security), add them to the `namespaces` list in `charts/values.yaml`.

## Agents

This repository uses a specialized agent to assist with documentation maintenance and accuracy.

### Available Agent

- **Documentation Maintenance Agent**:
  - Location: `.github/agents/documentation.md`
  - Purpose: Maintains and improves documentation files (`.md` and `.puml`).
  - Responsibilities:
    - Keeps README.md, copilot-instructions.md, and other docs synchronized with Taskfile.yaml and chart configuration
    - Ensures deployment instructions, examples, and namespace references are accurate
    - Analyzes code to verify documentation reflects current implementation
    - Updates configuration tables and PlantUML diagrams

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository and create a new branch for your changes.
2. Follow the repository's coding and documentation standards (see `CONTRIBUTING.md`).
3. Test your changes thoroughly.
4. Submit a pull request with a clear description of your changes.

For detailed guidance, refer to the `CONTRIBUTING.md` file.

## License

Apache 2.0. See `LICENSE` for details.
