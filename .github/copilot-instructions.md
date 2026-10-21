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
2. Review and customize `charts/values.yaml` as needed for Keycloak configuration.
3. Deploy all prerequisites with a single command:
   ```sh
   task install-all
   ```
   This will:
   - Add the Istio Helm repository (`https://blob.istio.io/istio-release/charts`)
   - Install Istio base and istiod to `istio-system` namespace
   - Install Istio gateway to `istio-ingress` namespace  
   - Install Keycloak and Postgres via the prerequisites Helm chart-of-charts
   
   Alternatively, run individual tasks:
   ```sh
   task add-istio-repo      # Add Istio Helm repository
   task install-istio       # Install all Istio components
   task install-prerequisites-chart  # Install Keycloak and Postgres
   ```

### Using Taskfile for Automation

- The `Taskfile.yaml` includes predefined automation steps for installation and testing. Key tasks include:
  - `task install-all`: Install all prerequisites (Istio + Keycloak) with a single command
  - `task add-istio-repo`: Add the Istio Helm repository
  - `task install-istio`: Install Istio base, istiod, and gateway
  - `task install-prerequisites-chart`: Install Keycloak and Postgres
  - `task lint`: Lint all Helm charts for syntax errors
  - `task test`: Run BDD tests

## Testing and Debugging

- Tests are located in the `tests/` directory and use BDD with Cucumber.
- To run tests, use the Taskfile task:
  ```sh
  task test
  ```
- Or run manually: ensure Node.js is installed, then:
  ```sh
  cd tests && npm install && npm test
  ```
- See `tests/README.md` for setup and manual test execution instructions.

## Integration Points

- **Istio**: Provides service mesh capabilities. Installed via Taskfile tasks:
  - Istio base and istiod are installed to `istio-system` namespace
  - Istio gateway is installed to `istio-ingress` namespace
  - Use the standard Istio repository: `https://blob.istio.io/istio-release/charts`
- **Keycloak**: A dependent chart for identity management. Deployed to the `keycloak` namespace (or custom namespace if configured). Customize its `values.yaml` in `identity/keycloak/` for specific configurations.
- **Service Mesh**: Istio provides service mesh capabilities. Refer to the Istio documentation for further configuration beyond the base and istiod installation.

## Namespace Management

The canvas-prerequisites uses a centralized namespace management approach:

### Canvas Prerequisites Namespaces
Defined in `charts/values.yaml` under the `namespaces` list. These are created automatically by Helm as part of the chart-of-charts deployment:
```yaml
namespaces:
  - keycloak
```

The Helm template `charts/templates/namespaces.yaml` uses a `range` loop to create a Namespace resource for each entry in this list. This provides:
- **Single source of truth**: Add new namespaces only to the values list
- **Scalability**: Easily add observability, security, or other prerequisite namespaces
- **Automatic ordering**: Namespaces created before other resources (Helm resource ordering)

### Istio Infrastructure Namespaces
Created by Taskfile tasks during `task install-istio`:
- `istio-system`: Istio base and istiod (control plane)
- `istio-ingress`: Istio gateway (ingress component)

These are created separately to maintain clean separation between infrastructure (Istio) managed via Task and application prerequisites (Keycloak) managed via Helm.

### Adding New Prerequisite Namespaces
To add a new prerequisite namespace (e.g., observability):
1. Edit `charts/values.yaml` and add to the `namespaces` list:
   ```yaml
   namespaces:
     - keycloak
     - observability
   ```
2. The Helm template automatically creates the namespace when you run `helm install prerequisites ./charts`