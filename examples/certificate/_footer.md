## Certificate Options

This example demonstrates two patterns:

### 1. Direct Certificate Upload

Use `certificate_value` (base64-encoded) and `certificate_password` for direct upload:

```hcl
certificates = {
  "example-cert" = {
    certificate_value    = filebase64("./mycert.pfx")
    certificate_password = "MyPassword123!"
  }
}
```

### 2. Key Vault Reference

Use `key_vault_secret_id` to reference a certificate stored in Azure Key Vault:

```hcl
certificates = {
  "example-cert" = {
    key_vault_secret_id = "https://myvault.vault.azure.net/secrets/mycert/version"
  }
}
```

## Security Considerations

- Certificate passwords are sensitive and should be stored securely (e.g., Azure Key Vault, environment variables)
- Key Vault references require appropriate RBAC or access policy permissions
- Always use managed identity when possible for Key Vault authentication
