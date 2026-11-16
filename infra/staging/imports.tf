# 手で設定していたものを取り込む。apply で取り込まれた後は消してよい。

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

import {
  to = module.nocsis.google_iam_workload_identity_pool.github
  id = "projects/nocsis-development/locations/global/workloadIdentityPools/github-action"
}

import {
  to = module.nocsis.google_iam_workload_identity_pool_provider.github
  id = "projects/nocsis-development/locations/global/workloadIdentityPools/github-action/providers/deploy-nocsis"
}

import {
  for_each = module.nocsis.import_ids.service_accounts
  to       = module.nocsis.google_service_account.this[each.key]
  id       = each.value
}

import {
  to = module.nocsis.google_service_account_iam_member.wlif_build
  id = "projects/nocsis-development/serviceAccounts/wlif-build@nocsis-development.iam.gserviceaccount.com roles/iam.workloadIdentityUser principal://iam.googleapis.com/projects/862064818225/locations/global/workloadIdentityPools/github-action/subject/canoypa/nocsis"
}

import {
  to = module.nocsis.google_service_account_iam_binding.wlif_deploy
  id = "projects/nocsis-development/serviceAccounts/wlif-deploy@nocsis-development.iam.gserviceaccount.com roles/iam.workloadIdentityUser"
}

import {
  for_each = module.nocsis.import_ids.wlif_deploy_acts_as
  to       = module.nocsis.google_service_account_iam_member.wlif_deploy_acts_as[each.key]
  id       = each.value
}

import {
  for_each = module.nocsis.import_ids.custom_roles
  to       = module.nocsis.google_project_iam_custom_role.this[each.key]
  id       = each.value
}

import {
  for_each = module.nocsis.import_ids.project_iam
  to       = module.nocsis.google_project_iam_member.this[each.key]
  id       = each.value
}

import {
  for_each = module.nocsis.import_ids.secrets
  to       = module.nocsis.google_secret_manager_secret.this[each.key]
  id       = each.value
}

import {
  for_each = module.nocsis.import_ids.secret_accessors
  to       = module.nocsis.google_secret_manager_secret_iam_binding.accessor[each.key]
  id       = each.value
}
