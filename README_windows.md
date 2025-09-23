# Spring Boot → GKE — Windows + Kustomize/Helm
PowerShell 前提の手順と、Kustomize/Helm 両対応の最小テンプレートです。

## 必須ツール（Windows）
- Git, Java 17, Docker Desktop(WSL2), kubectl, gcloud, (任意) Helm
## ローカル実行
./mvnw.cmd -q -DskipTests package
docker build -t demo:local .
docker run --rm -p 8080:8080 demo:local
## GCP 初期設定
tools/windows/bootstrap.ps1 を編集して実行。
## Kustomize 適用
kubectl apply -k kustomize/overlays/dev
## Helm 適用
helm upgrade --install demo ./helm/demo --namespace demo --create-namespace -f helm/demo/values.yaml -f helm/demo/values-dev.yaml --set image.repository=$Env:GCP_REGION-docker.pkg.dev/$Env:GCP_PROJECT_ID/demo-repo/demo --set image.tag=LOCAL
