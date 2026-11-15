# infra

Staging (`nocsis-development`) と本番 (`class-clock-40088`) の GCP / Firebase の設定を Terraform で管理する。

| ディレクトリ | 中身 |
| --- | --- |
| `modules/nocsis/` | 両環境に共通の定義 |
| `staging/` / `production/` | 環境ごとの値と state の置き場 |
| `bootstrap/` | Terraform が自分では作れないもの (state バケットと Terraform 自身の SA) を作るスクリプト |

## 反映の流れ

- PR を出すと、`infra.yml` が両環境の `plan` を流す。結果は Actions の Summary に、変えるリソースの一覧だけが出る。
- `development` にマージすると Staging に、`main` にマージすると本番に `apply` される。本番は Production environment の承認を通る。

公開リポジトリの Actions のログと artifact は誰でも読めるため、plan / apply の本文は出さない。

## 置かないもの

- Secret の値。Terraform は Secret の入れ物と IAM だけを持つ。
- 人のメールアドレスなど、個人を特定できる値。Actions の secret から `sensitive` な変数で渡す。

## 初回だけの準備

プロジェクトの owner が、プロジェクトごとに一度だけ流す。

```sh
./bootstrap/bootstrap.sh nocsis-development Staging
./bootstrap/bootstrap.sh class-clock-40088 Production
```

| 作るもの | 用途 |
| --- | --- |
| `<project>-tfstate` バケット | state。非公開・バージョニング有効 |
| `tf-plan` SA | PR の plan 用。設定と state を読むだけ。リポジトリに束縛 |
| `tf-apply` SA | apply 用。そのプロジェクトの environment にだけ束縛 |

## 手元で plan を見る

state バケットを読める権限があれば、手元でも見られる。

```sh
cd infra/staging
terraform init
terraform plan -lock=false
```
