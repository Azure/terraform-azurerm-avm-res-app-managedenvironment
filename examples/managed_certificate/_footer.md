## Domain Validation Methods

Azure supports three domain validation methods:

### 1. CNAME Validation (Recommended)

Create a CNAME record pointing to the Azure validation endpoint:

```
_acme-challenge.yourdomain.com CNAME <validation-endpoint>
```

### 2. TXT Validation

Create a TXT record with the validation token:

```
_acme-challenge.yourdomain.com TXT <validation-token>
```

### 3. HTTP Validation

Host a validation file at:

```
http://yourdomain.com/.well-known/acme-challenge/<token>
```

## Certificate Lifecycle

- **Provisioning**: Takes several minutes after DNS validation completes
- **Renewal**: Automatically renewed by Azure before expiration
- **Validation**: Azure periodically re-validates domain ownership

## Important Notes

- DNS propagation can take up to 48 hours (typically much faster)
- The managed environment must be created before certificates can be provisioned
- Changes to validation configuration may trigger re-validation
- Managed certificates are free and automatically renewed by Azure
