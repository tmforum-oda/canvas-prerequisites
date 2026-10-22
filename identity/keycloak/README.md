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
| `namespace`                       | Kubernetes namespace for Keycloak and Postgres  | `keycloak`                     |
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

## Namespace Configuration

By default, Keycloak and Postgres are deployed to the `keycloak` namespace. This namespace is created automatically by Helm as part of the chart deployment.

### Using a Custom Namespace

To deploy Keycloak to a different namespace, override the `namespace` value:

```sh
helm install my-keycloak ./keycloak --set namespace=my-custom-ns
```

Or configure it in your values file:

```yaml
namespace: my-custom-ns
```

**Note:** If you're using this chart as a dependency in a parent chart (chart-of-charts), you need to also update the `global.keycloakNamespace` value to ensure the Postgres subchart uses the same namespace:

```yaml
namespace: my-custom-ns
global:
  keycloakNamespace: my-custom-ns
```

### Accessing Keycloak Resources by Namespace

After installation, verify the resources are in the correct namespace:

```sh
# Check StatefulSet
kubectl get statefulset -n keycloak

# Check Services
kubectl get svc -n keycloak

# Check Secrets
kubectl get secret -n keycloak
```

### Cross-Namespace Access

If other services in your cluster (e.g., API Gateway, other Canvas components) need to access Keycloak from a different namespace, use the Kubernetes fully qualified domain name (FQDN):

```
http://keycloak.keycloak.svc.cluster.local:8080
```

For a custom namespace:

```
http://keycloak.<namespace>.svc.cluster.local:8080
```

**Example:** If Keycloak is in namespace `identity-services` and another service in `api-gateway` needs to call it:

```
http://keycloak.identity-services.svc.cluster.local:8080
```

This FQDN format is standard Kubernetes service discovery and works across all namespaces without additional networking configuration, assuming no NetworkPolicies or security rules restrict traffic.

## Password Management

- **Admin and database passwords** are stored in a Kubernetes Secret named `keycloak-credentials`.
- If you do not set a password in `values.yaml`, a random password will be generated at install time and given to you by Helm after the installation is complete.

### Setting the Admin Password via Helm

You can set a custom admin password at install time using:

```sh
helm install my-keycloak ./keycloak-helm --set keycloak.adminPassword=yourStrongPassword
```

### Retrieving Passwords

To get the Keycloak admin password (default namespace `keycloak`):

```sh
kubectl get secret keycloak-credentials -n keycloak -o jsonpath='{.data.keycloak-admin-password}' | base64 --decode
```

For a custom namespace, replace `keycloak` with your namespace name:

```sh
kubectl get secret keycloak-credentials -n <your-namespace> -o jsonpath='{.data.keycloak-admin-password}' | base64 --decode
```

To get the Postgres password:

```sh
kubectl get secret keycloak-credentials -n keycloak -o jsonpath='{.data.postgres-password}' | base64 --decode
```

## Default Admin Credentials

- Username: `admin`
- Password: See above for retrieval instructions.

## Upgrade & Secret Preservation

### How Secret Preservation Works

The Keycloak admin password and Postgres password Secret is protected with the Helm annotation `helm.sh/resource-policy: keep`. This means:

- **First install**: A Secret is created. If you did not specify passwords in values, random passwords are generated.
- **Helm upgrades**: The existing Secret is **NOT overwritten**. Your current credentials are preserved, ensuring Keycloak continues to function without interruption.
- **Manual changes**: If you manually modify or delete the Secret outside of Helm, subsequent Helm operations will not recreate it automatically.

### Storing Initial Passwords Securely

After the first install, the randomly generated passwords are embedded in the Secret. **Store them securely** before performing upgrades:

```sh
kubectl get secret <release-name>-credentials -n keycloak -o jsonpath='{.data.keycloak-admin-password}' | base64 --decode
kubectl get secret <release-name>-credentials -n keycloak -o jsonpath='{.data.postgres-password}' | base64 --decode
```

For a custom namespace:

```sh
kubectl get secret <release-name>-credentials -n <your-namespace> -o jsonpath='{.data.keycloak-admin-password}' | base64 --decode
kubectl get secret <release-name>-credentials -n <your-namespace> -o jsonpath='{.data.postgres-password}' | base64 --decode
```

It is recommended to save these values immediately after the first installation.

### Rotating Passwords

If you need to rotate passwords after deployment:

1. Create a new Secret with updated credentials:
   ```sh
   kubectl create secret generic <release-name>-credentials-new \\
     --from-literal=keycloak-admin-user=admin \\
     --from-literal=keycloak-admin-password=<new-password> \\
     --from-literal=postgres-user=keycloak \\
     --from-literal=postgres-password=<new-postgres-password> \\
     -o yaml | kubectl apply -f -
   ```

2. Update the StatefulSet to reference the new Secret (or manually restart Keycloak pods to pick up the updated Secret data).

3. Delete the old Secret after verifying everything works:
   ```sh
   kubectl delete secret <release-name>-credentials
   ```

### Force-Regenerating the Secret

If you need to regenerate the Secret from Helm (e.g., to reset to a random password), you must first remove the resource-policy protection:

1. Remove the Helm annotation:
   ```sh
   kubectl annotate secret <release-name>-credentials helm.sh/resource-policy- --overwrite
   ```

2. Delete the Secret:
   ```sh
   kubectl delete secret <release-name>-credentials
   ```

3. Run Helm upgrade/install to recreate it:
   ```sh
   helm upgrade <release-name> ./keycloak --reuse-values
   ```
   This will create a new Secret with randomly generated passwords.

## Accessing the Keycloak UI

Get the service URL in the default namespace:

```sh
kubectl get svc <release-name>-keycloak -n keycloak
```

For a custom namespace:

```sh
kubectl get svc <release-name>-keycloak -n <your-namespace>
```

Replace `<release-name>` with your Helm release name and `<your-namespace>` with the namespace where you deployed Keycloak.

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