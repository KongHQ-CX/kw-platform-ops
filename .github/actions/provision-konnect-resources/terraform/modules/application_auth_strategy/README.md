This module creates a Konnect Application Auth Strategy (konnect_application_auth_strategy).

Inputs:

- name (string)
- display_name (string, optional)
- labels (map(string), optional)
- strategy_type (string): key_auth | openid_connect
- key_auth_key_names (list(string), optional) when strategy_type=key_auth
- oidc\_\* variables (optional) when strategy_type=openid_connect

Outputs:

- id: Application Auth Strategy ID
