# Copilot Usage Instructions

## Project Overview

This repository contains the prerequisites for the TM Forum Open Digital Architecture (ODA) Canvas Reference Implementation. The ODA Canvas is an execution environment for ODA Components. The prerequisites are a package of Helm charts that deploy the necessary infrastructure components required by the ODA Canvas.

## Key Concepts and Terminology

- **ODA Canvas**: An execution environment that supports ODA Components by providing access to cloud-native services required by the components (API Gateway, Service Mesh, Observability services, Identity Management, etc.).
- **ODA Component**: Software components that follow the ODA Component Specification, which the Canvas reads as metadata to execute lifecycle processes.
- **Operators**: Management-plane functions that manage ODA Components by reading the Component's requirements and executing lifecycle processes. Operators follow the Kubernetes Operator Pattern.
- **Webhooks**: Used to integrate with the Kubernetes Control Plane, supporting multiple versions of the ODA Component Standard.
- **BDD (Behaviour-Driven Development)**: The approach used to document and test Canvas behaviors through features and scenarios.

## Modular Architecture

The ODA Canvas implements a modular architecture with independent operators:

- **Component Management**: Manages the lifecycle of each component and handles decomposition into ExposedAPIs, IdentityConfigs, and other sub-resources.
- **API Management**: Manages API Gateway and/or Service Mesh to provide security, throttling, and other non-functional services.
- **Identity Config**: Configures Identity Management Services.
- **Secrets Management**: Optional operator for configuring secrets.
- **Dependency Management**: Allows Components to discover API dependencies.

## Project Structure

- **charts/**: Helm chart-of-charts for deploying Canvas prerequisites.
- **identity/**: Dependent charts for identity management installation.
- **tests/**: Contains BDD tests using Cucumber.
- **Taskfile.yaml**: Automation steps for installing prerequisites.
- **LICENSE**: Apache 2.0 license file.
- **.gitignore**: Git ignore file.

## Development Guidelines

- Use clear, descriptive comments in Helm templates and values files.
- Structure charts with logical separation: chart-of-charts in `charts/`, dependent charts in category-based folders (for example, Keycloak in `identity/keycloak/`).
- Prefer concise, modular YAML and shell scripts.
- Document custom resources and values in README and comments.
- When adding new prerequisites, create a new dependent chart in a category-based folder. If unsure about the folder, ask.
- Use values files to parameterise deployments.
- Values should only be exposed in the chart-of-charts if we expect customisation of the installation (for example enabling/disabling dependencies or changing passwords in dependencies).

## Developer Workflows

### Setting Up the Environment

1. Ensure you have the following tools installed:
   - [Helm](https://helm.sh/)
   - [kubectl](https://kubernetes.io/docs/tasks/tools/)
2. Access a running Kubernetes cluster.

### Deploying the Prerequisites

1. Clone this repository.
2. Install Istio:
   ```sh
   helm repo add istio https://istio-release.storage.googleapis.com/charts
   helm repo update
   helm install istio-base istio/base
   helm install istiod istio/istiod
   ```
   Refer to the Istio documentation for further configuration.
3. Customize `charts/values.yaml` as needed.
4. Deploy the chart-of-charts:
   ```sh
   helm install prerequisites ./charts
   ```

### Using Taskfile for Automation

- The `Taskfile.yaml` includes predefined automation steps. For example, to install prerequisites, run:
  ```sh
  task install
  ```

## Testing and Debugging

- Tests are located in the `tests/` directory and use BDD with Cucumber.
- To run tests, ensure Node.js is installed and execute:
  ```sh
  npm install
  npm test
  ```

## Integration Points

- **Istio**: Provides service mesh capabilities. Ensure it is installed and configured before deploying the chart-of-charts.
- **Keycloak**: A dependent chart for identity management. Customize its `values.yaml` in `identity/keycloak/` for specific configurations.

## Configuration Values

Refer to the `charts/values.yaml` file for global configurations. For sub-chart-specific values, see the `values.yaml` in the respective directories (e.g., `identity/keycloak/values.yaml`).