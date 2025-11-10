# Keycloak Helm Chart

This chart deploys Keycloak and Postgres on Kubernetes.It is derived from the official manifest provided by the Keycloak team in their [Kubernetes Getting Started guide](https://www.keycloak.org/getting-started/getting-started-kube), with enhancements for Helm packaging, parameterisation, and secret management. **It is not intended for production use**, but customised for installation as a prerequisite for the TM Forum Open Digital Architecture Canvas Reference Implementation produced by the [Innovation Hub](https://www.tmforum.org/member-projects/innovation-hubs).


## Usage

```sh
helm install my-keycloak ./keycloak-helm
```

Customize values in `values.yaml` as needed or override with `--set`.

## Values

| Parameter                        | Purpose                                         | Default                        |
|-----------------------------------|-------------------------------------------------|--------------------------------|
| `keycloak.image.repository`       | Keycloak image repository                       | `quay.io/keycloak/keycloak`    |
| `keycloak.image.tag`              | Keycloak image tag/version                      | `26.4.2`                       |
| `keycloak.replicas`               | Number of Keycloak pods                         | `1`                            |
| `keycloak.resources.requests.cpu` | CPU request for Keycloak pod                    | `500m`                         |
| `keycloak.resources.requests.memory` | Memory request for Keycloak pod               | `1700Mi`                       |
| `keycloak.resources.limits.cpu`   | CPU limit for Keycloak pod                      | `2000m`                        |
| `keycloak.resources.limits.memory`| Memory limit for Keycloak pod                   | `2000Mi`                       |
| `keycloak.service.type`           | Keycloak service type                           | `LoadBalancer`                 |
| `keycloak.service.port`           | Keycloak HTTP service port                      | `8080`                         |
| `keycloak.service.healthPort`     | Keycloak health endpoint port                   | `9000`                         |
| `keycloak.adminUser`              | Keycloak admin username                         | `admin`                        |
| `keycloak.adminPassword`          | Keycloak admin password (blank for random)      | `""`                           |
| `keycloak.hostnameStrict`         | Hostname strict mode                            | `false`                        |
| `keycloak.healthEnabled`          | Enable health checks                            | `true`                         |
| `keycloak.cache`                  | Cache provider                                  | `ispn`                         |
| `keycloak.proxyHeaders`           | Proxy header mode                               | `xforwarded`                   |
| `keycloak.httpEnabled`            | Enable HTTP                                     | `true`                         |
| `keycloak.importJob.enabled`      | Enable import job (for custom import logic)     | `false`                        |
| `keycloak.configCli.image.repository` | keycloak-config-cli image repo               | `quay.io/adorsys/keycloak-config-cli` |
| `keycloak.configCli.image.tag`    | keycloak-config-cli image tag                   | `6.4.0-26`                     |
| `postgres.image.repository`       | Postgres image repository                       | `mirror.gcr.io/postgres`       |
| `postgres.image.tag`              | Postgres image tag/version                      | `17`                           |
| `postgres.user`                   | Postgres username                               | `keycloak`                     |
| `postgres.password`               | Postgres password (blank for random)            | `""`                           |
| `postgres.database`               | Postgres database name                          | `keycloak`                     |
| `postgres.service.port`           | Postgres service port                           | `5432`                         |

## Password Management

- **Admin and database passwords** are stored in a Kubernetes Secret named `keycloak-credentials`.
- If you do not set a password in `values.yaml`, a random password will be generated at install time and given to you by Helm after the installation is complete.

### Setting the Admin Password via Helm

You can set a custom admin password at install time using:

```sh
helm install my-keycloak ./keycloak-helm --set keycloak.adminPassword=yourStrongPassword
```

### Retrieving Passwords

To get the Keycloak admin password:

```sh
kubectl get secret keycloak-credentials -o jsonpath='{.data.keycloak-admin-password}' | base64 --decode
```

To get the Postgres password:

```sh
kubectl get secret keycloak-credentials -o jsonpath='{.data.postgres-password}' | base64 --decode
```

## Default Admin Credentials

- Username: `admin`
- Password: See above for retrieval instructions.

## Accessing the Keycloak UI

Get the service URL:

```sh
kubectl get svc <release-name>-keycloak
```
Replace `<release-name>` with your Helm release name.

## Chart Structure

- `templates/` contains all Kubernetes manifests.
- `values.yaml` contains all configurable parameters.
- `charts/postgres` is a subchart for Postgres.
- Secrets are managed via `templates/keycloak-secret.yaml`.

## Installation Details

This chart installs Keycloak and Postgres using a modular approach:

- **Keycloak StatefulSet:**  
  Deploys the Keycloak server using the official Keycloak container image.  
  The StatefulSet includes an initContainer to ensure the Postgres database is available before Keycloak starts.

- **Postgres Subchart:**  
  Deploys Postgres using a separate subchart for isolation and maintainability.  
  Credentials are  managed via Kubernetes Secrets.

- **keycloak-config-cli Job:**  
  After Keycloak is running, a Helm post-install Job runs the [adorsys/keycloak-config-cli](https://github.com/adorsys/keycloak-config-cli) image.  
  This job waits for Keycloak to be healthy, then applies configuration from your realm file(s).  
  The CLI image is used because it provides idempotent, declarative configuration management for Keycloak, making it easy to automate realm, client, and user setup.

- **Secrets:**  
  Admin and database credentials are stored in a Kubernetes Secret (`keycloak-credentials`).  
  Passwords are generated randomly if not set, and can be retrieved after install.

**Why different images and jobs?**

- The official Keycloak image is used for the main application to ensure compatibility and support.
- The adorsys/keycloak-config-cli image is used for configuration because it is purpose-built for importing and managing Keycloak configuration declaratively, and is run as a one-off Job to avoid sidecar lifecycle issues.
- Busybox is used for lightweight readiness checks and scripting in initContainers and jobs.