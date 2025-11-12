const { Given, When, Then } = require('@cucumber/cucumber');
const { execSync } = require('child_process');
const assert = require('assert');

Given('I have a clean environment', function () {
  // Example: Remove helm, istio repos, and releases.
  // Refactor as needed for your environment.
  try { execSync('sudo rm -f /usr/local/bin/helm'); } catch {}
  try { execSync('helm uninstall istio-base'); } catch {}
  try { execSync('helm uninstall istiod'); } catch {}
  try { execSync('helm uninstall prerequisites'); } catch {}
  try { execSync('helm repo remove istio'); } catch {}
});

Given('Helm is installed', function () {
  try { execSync('helm version'); }
  catch {
    throw new Error('Helm must be installed for this step.');
  }
});

Given('the Istio Helm repository is added', function () {
  const repos = execSync('helm repo list').toString();
  assert(repos.includes('istio'), 'Istio repo not found');
});

Given('Istio is installed', function () {
  const releases = execSync('helm list -A').toString();
  assert(releases.includes('istio-base'), 'istio-base not installed');
  assert(releases.includes('istiod'), 'istiod not installed');
});

When('I run the {string} task', function (taskName) {
  execSync(`task ${taskName}`, { stdio: 'inherit' });
});

Then('the {string} binary should be available in the PATH', function (binary) {
  try {
    execSync(`command -v ${binary}`);
  } catch {
    throw new Error(`${binary} not found in PATH`);
  }
});

Then('the Istio Helm repository should be present in the Helm repo list', function () {
  const repos = execSync('helm repo list').toString();
  assert(repos.includes('istio'), 'Istio repo not found');
});

Then('the {string} and {string} releases should be deployed in the cluster', function (release1, release2) {
  const releases = execSync('helm list -A').toString();
  assert(releases.includes(release1), `${release1} not installed`);
  assert(releases.includes(release2), `${release2} not installed`);
});

Then('the {string} release should be deployed in the cluster', function (release) {
  const releases = execSync('helm list -A').toString();
  assert(releases.includes(release), `${release} not installed`);
});

Then('Helm, Istio, and the prerequisites chart should all be installed', function () {
  try { execSync('helm version'); } catch { throw new Error('Helm not installed'); }
  const releases = execSync('helm list -A').toString();
  assert(releases.includes('istio-base'), 'istio-base not installed');
  assert(releases.includes('istiod'), 'istiod not installed');
  assert(releases.includes('prerequisites'), 'prerequisites chart not installed');
});
