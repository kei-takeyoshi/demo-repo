param([string]$FilePath="k8s/deployment.yaml",[string]$Image="REGION-docker.pkg.dev/PROJECT/REPO/demo:TAG")
$Content = Get-Content $FilePath -Raw
$Content = $Content -replace "REPLACE_WITH_IMAGE", $Image
Set-Content -Path $FilePath -Value $Content -NoNewline
