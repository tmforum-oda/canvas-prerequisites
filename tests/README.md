# BDD Test Suite for ODA Canvas Prerequisites

This folder contains BDD (Behaviour-Driven Development) tests for the installation of ODA Canvas prerequisites using [Cucumber](https://cucumber.io/).

## Assumptions and Prerequisites

- **Kubernetes Cluster**: You have access to a running Kubernetes cluster (e.g., via `kubectl`).
- **kubectl**: Installed and configured to access your cluster.
- **Helm**: Installed and available in your PATH.
- **Cucumber**: You have [Cucumber.js](https://github.com/cucumber/cucumber-js) or another Cucumber implementation installed.
- **Clean Environment**:  
  - No Istio Helm repositories added (`helm repo list` does not include Istio).
  - No Istio or prerequisites Helm releases present in the cluster (`helm list` does not include `istio-base`, `istiod`, or `prerequisites`).
  - No leftover resources from previous test runs.

> **Note:** All tests assume you are running the installation and verification steps manually using `helm`, `kubectl`, and other CLI tools. The use of Task is only provided as an example in this repository and is not required for running or verifying these tests.

## Running the Tests

1. Ensure all prerequisites above are met.
2. For each scenario in the feature file, manually execute the described steps using the CLI (e.g., `helm`, `kubectl`).
3. Use the expected outcomes in the `Then` steps to verify success (e.g., check binaries in PATH, Helm repos, or deployed releases).

## Refactoring

- If your environment or requirements differ, update the step definitions and this README accordingly.
