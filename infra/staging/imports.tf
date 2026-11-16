# 手で設定していたものを取り込む (#1406)。apply で取り込まれた後は消してよい。

import {
  to = module.nocsis.google_identity_platform_config.this
  id = "projects/nocsis-development/config"
}

import {
  to = module.nocsis.google_identity_platform_default_supported_idp_config.google
  id = "projects/nocsis-development/defaultSupportedIdpConfigs/google.com"
}

import {
  to = module.nocsis.google_firebase_hosting_site.default
  id = "projects/nocsis-development/sites/nocsis-development"
}
