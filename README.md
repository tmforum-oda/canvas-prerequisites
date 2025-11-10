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
- `COPILOT.md`: Instructions for optimising GitHub Copilot usage

## Usage

1. Clone this repo
2. Install Helm
3. Deploy the chart-of-charts:
   ```sh
   helm install prerequisites ./charts
   ```
4. Configure sub-charts as needed

## Contributing

See `COPILOT.md` for guidance on using Copilot and contributing.

## License

Apache 2.0. See `LICENSE` for details.
