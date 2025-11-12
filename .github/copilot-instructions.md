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