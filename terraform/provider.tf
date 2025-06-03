terraform {
  required_providers {
    yandex = {
      source  = "yandex-cloud/yandex"
      version = ">= 0.13"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = ">= 3.57.0"
    }
  }
}

provider "yandex" {
  zone      = var.yc_zone
  token     = var.yc_token
  folder_id = var.yc_folder
}

//provider "datadog" {
  //api_key = var.datadog_api_key
  //api_url = var.datadog_url
//}
