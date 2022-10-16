terraform {
  # backend の設定では variable を使えないので直書きする
  backend "s3" {
    region  = "ap-northeast-1"
    bucket  = "laravel-fargate-terraform"
    key     = "dev/laravel-fargate.tfstate"
    encrypt = true
  }
}