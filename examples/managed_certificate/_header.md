# Managed Certificate Example

This example demonstrates how to configure Azure-managed certificates for a Container Apps Managed Environment. Azure automatically provisions and renews these certificates.

> **Note**: This example requires domain ownership and DNS configuration. See Prerequisites below.

## Prerequisites

- A registered domain name that you own
- DNS management access for the domain
- Ability to create DNS records for domain validation:
  - **CNAME** record pointing to Azure validation endpoint, OR
  - **TXT** record with validation token, OR
  - **HTTP** validation file hosted on the domain
