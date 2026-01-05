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
- `test`: Run BDD tests (`cd tests && npm install && npm test`)
- `lint`: Lint YAML files (`yamllint charts/ identity/`)

> Note: Helm installation and cluster setup are not automated in the Taskfile. Please follow the manual steps in the Usage section.

## Testing

- BDD tests are in `tests/` and use Cucumber.js.
- See `tests/README.md` for setup and manual test execution instructions.

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
   kubectl create namespace istio-system
   helm install istio-base istio/base -n istio-system --wait
   helm install istiod istio/istiod -n istio-system --wait
   ```
3. Review and customise values in `charts/values.yaml` as needed.
4. Deploy the chart-of-charts:
   ```sh
   helm install prerequisites ./charts
   ```
5. Configure dependent charts as needed

> **Note:** This repository includes a `Taskfile.yaml` with example automation steps for installing prerequisites.

## Configuration Values

The following table lists the main values exposed for customisation in the chart-of-charts. For a full list of configurable values for sub-charts and dependencies (such as Keycloak), refer to the `values.yaml` file in each dependent chart directory (e.g., `identity/keycloak/values.yaml`).

| Key                          | Default Value | Source                | Type    | Purpose                                      |
|------------------------------|--------------|-----------------------|---------|----------------------------------------------|
| `keycloak.enabled`           | `true`       | chart-of-charts       | boolean | Enable/disable Keycloak deployment           |
| `keycloak.username`          | `""`         | Keycloak sub-chart    | string  | Keycloak admin username (uses chart default) |
| `keycloak.password`          | `""`         | Keycloak sub-chart    | string  | Keycloak admin password (uses chart default) |
| `keycloak.postgres.username` | `""`         | Keycloak sub-chart    | string  | Postgres DB username for Keycloak (default)  |
| `keycloak.postgres.password` | `""`         | Keycloak sub-chart    | string  | Postgres DB password for Keycloak (default)  |

## Agents

This repository uses specialized agents to assist with specific tasks. Each agent is designed to handle a particular aspect of the project, ensuring clarity and maintainability.

### Available Agents

- **Documentation Maintenance Agent**:
  - Location: `.github/agents/documentation.md`
  - Purpose: Maintains and improves documentation files (`.md` and `.puml`).
  - Responsibilities:
    - Updates markdown files such as `README.md` and `CONTRIBUTING.md`.
    - Keeps PlantUML diagrams up-to-date.
    - Analyzes the codebase to ensure documentation reflects the current state of the project.
- **Taskfile Maintenance Agent**:
  - Location: `.github/agents/taskfile.md`
  - Purpose: Creates and maintains `Taskfile.yaml` for automation.
  - Responsibilities:
    - Adds or updates tasks for testing, linting, and other automation.
    - Ensures tasks are clear, functional, and documented.

### Adding New Agents

To add a new agent, create a markdown file in the `.github/agents/` directory. The file should include:
- The agent's purpose.
- Key responsibilities.
- Guidelines for operation.
- Examples of tasks the agent can perform.

## Contributing

Contributions are welcome! To contribute:

1. Fork the repository and create a new branch for your changes.
2. Follow the repository's coding and documentation standards (see `CONTRIBUTING.md`).
3. Test your changes thoroughly.
4. Submit a pull request with a clear description of your changes.

For detailed guidance, refer to the `CONTRIBUTING.md` file.

## License

Apache 2.0. See `LICENSE` for details.
