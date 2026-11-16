# 手で設定していたものを取り込む (#1406)。apply で取り込まれた後は消してよい。

import {
  to = module.nocsis.google_identity_platform_config.this
  id = "projects/class-clock-40088/config"
}

import {
  to = module.nocsis.google_identity_platform_default_supported_idp_config.google
  id = "projects/class-clock-40088/defaultSupportedIdpConfigs/google.com"
}

import {
  to = module.nocsis.google_firebase_hosting_site.default
  id = "projects/class-clock-40088/sites/class-clock-40088"
}

import {
  to = module.nocsis.google_firebase_hosting_custom_domain.this["nocsis.app"]
  id = "projects/class-clock-40088/sites/class-clock-40088/customDomains/nocsis.app"
}
