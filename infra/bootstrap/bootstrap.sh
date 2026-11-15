#!/usr/bin/env bash
# Terraform が自分では作れないもの (state バケットと Terraform 自身の SA) を作る。
# プロジェクトの owner が、プロジェクトごとに一度だけ手で流す。
#
#   ./bootstrap.sh nocsis-development Staging
#   ./bootstrap.sh class-clock-40088 Production
#
# ここで作ったものは、あとで Terraform に import して管理下に入れる。
set -euo pipefail

PROJECT_ID=${1:?プロジェクト ID を渡す}
ENVIRONMENT=${2:?GitHub の environment 名 (Staging / Production) を渡す}

case "$PROJECT_ID:$ENVIRONMENT" in
  nocsis-development:Staging | class-clock-40088:Production) ;;
  *) echo "プロジェクトと environment の組み合わせが違う: $PROJECT_ID / $ENVIRONMENT" >&2; exit 1 ;;
esac

REGION=asia-northeast1
BUCKET="$PROJECT_ID-tfstate"
PROJECT_NUMBER=$(gcloud projects describe "$PROJECT_ID" --format='value(projectNumber)')
POOL="projects/$PROJECT_NUMBER/locations/global/workloadIdentityPools/github-action"
PLAN_SA="tf-plan@$PROJECT_ID.iam.gserviceaccount.com"
APPLY_SA="tf-apply@$PROJECT_ID.iam.gserviceaccount.com"

exists() { "$@" >/dev/null 2>&1; }

# state には全リソースの詳細が入る。公開しない・消えても戻せるようにする。
exists gcloud storage buckets describe "gs://$BUCKET" ||
  gcloud storage buckets create "gs://$BUCKET" --project "$PROJECT_ID" --location "$REGION" \
    --uniform-bucket-level-access --public-access-prevention
gcloud storage buckets update "gs://$BUCKET" --versioning

exists gcloud iam service-accounts describe "$PLAN_SA" --project "$PROJECT_ID" ||
  gcloud iam service-accounts create tf-plan --project "$PROJECT_ID" --display-name "Terraform plan (read-only)"
exists gcloud iam service-accounts describe "$APPLY_SA" --project "$PROJECT_ID" ||
  gcloud iam service-accounts create tf-apply --project "$PROJECT_ID" --display-name "Terraform apply"

bind_project() {
  gcloud projects add-iam-policy-binding "$PROJECT_ID" \
    --member "serviceAccount:$1" --role "$2" --condition None >/dev/null
}

# plan は設定を読むだけ。roles/viewer は Firestore のドキュメントまで読めるので使わない。
exists gcloud iam roles describe tfConfigReader --project "$PROJECT_ID" ||
  gcloud iam roles create tfConfigReader --project "$PROJECT_ID" \
    --title "Terraform config reader" \
    --permissions firebaseauth.configs.get,datastore.databases.get,datastore.indexes.list
for role in "projects/$PROJECT_ID/roles/tfConfigReader" roles/browser \
  roles/firebasehosting.viewer roles/run.viewer roles/secretmanager.viewer \
  roles/iam.securityReviewer roles/iam.serviceAccountViewer \
  roles/iam.workloadIdentityPoolViewer roles/serviceusage.serviceUsageViewer; do
  bind_project "$PLAN_SA" "$role"
done

# apply は IAM を管理するので projectIamAdmin が要る。ほかのロールは Terraform が
# 自分に付ける。強い権限なので、引けるのは environment の承認を通ったジョブだけ。
for role in roles/browser roles/resourcemanager.projectIamAdmin roles/iam.roleAdmin \
  roles/iam.serviceAccountAdmin roles/iam.workloadIdentityPoolAdmin \
  roles/serviceusage.serviceUsageAdmin; do
  bind_project "$APPLY_SA" "$role"
done

# plan は PR 上で -lock=false で流すので、state は読めれば足りる。
gcloud storage buckets add-iam-policy-binding "gs://$BUCKET" \
  --member "serviceAccount:$PLAN_SA" --role roles/storage.objectViewer >/dev/null
gcloud storage buckets add-iam-policy-binding "gs://$BUCKET" \
  --member "serviceAccount:$APPLY_SA" --role roles/storage.objectAdmin >/dev/null

# plan はブランチを問わず PR で流すので、wlif-build と同じくリポジトリに束縛する。
gcloud iam service-accounts add-iam-policy-binding "$PLAN_SA" --project "$PROJECT_ID" \
  --role roles/iam.workloadIdentityUser \
  --member "principal://iam.googleapis.com/$POOL/subject/canoypa/nocsis" >/dev/null
# apply はこのプロジェクトに対応する environment だけに束縛する。
gcloud iam service-accounts add-iam-policy-binding "$APPLY_SA" --project "$PROJECT_ID" \
  --role roles/iam.workloadIdentityUser \
  --member "principalSet://iam.googleapis.com/$POOL/attribute.environment/$ENVIRONMENT" >/dev/null

echo "done: $PROJECT_ID ($ENVIRONMENT)"
