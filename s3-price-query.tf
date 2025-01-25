provider "aws" {
  alias  = "global"
  region = "us-east-1"
}
data "aws_regions" "this" {}
data "aws_region" "current" {}
data "aws_region" "this" {
  for_each = toset(data.aws_regions.this.names)
  name     = each.key
}

data "aws_pricing_product" "storage_standard" {
  provider = aws.global
  for_each = toset([for _ in data.aws_region.this : _.name])

  service_code = "AmazonS3"

  filters {
    field = "availability"
    value = "99.99%"
  }
  filters {
    field = "durability"
    value = "99.999999999%"
  }
  filters {
    field = "productFamily"
    value = "Storage"
  }
  filters {
    field = "regionCode"
    value = each.key
  }
  filters {
    field = "storageClass"
    value = "General Purpose"
  }
  filters {
    field = "volumeType"
    value = "Standard"
  }
}

locals {
  terms = {
    for k, _ in data.aws_pricing_product.storage_standard : k => {
      for _result in [jsondecode(_.result)] : k => [
        for _terms in [[
          for l, _dim in [
            for _term in _result.terms.OnDemand : _term.priceDimensions
          ][0] : _dim if _dim.beginRange == "0"
          ][0]] : {
          result = _result
          terms  = _terms
        }
      ][0]
    }[k]
  }
  prices = distinct(sort([
    for _terms in local.terms : _terms.terms.pricePerUnit.USD
  ]))
  termsOrdered = compact(flatten([
    for value in local.prices : [
      for k, _ in local.terms : k if _.terms.pricePerUnit.USD == value
    ]
  ]))
}

output "prices" {
  value = {
    asset = "${local.terms[local.termsOrdered[0]].result.product.attributes.servicename}: ${local.terms[local.termsOrdered[0]].result.product.attributes.storageClass} ${local.terms[local.termsOrdered[0]].result.product.productFamily}"
    cheapest = {
      location = "${local.terms[local.termsOrdered[0]].result.product.attributes.regionCode} ${local.terms[local.termsOrdered[0]].result.product.attributes.location}"
      price = {
        "1.)   1GB-Mo" = "${format("%6.2f", ceil(local.terms[local.termsOrdered[0]].terms.pricePerUnit.USD * 100 * 1) / 100)}"
        "2.)  10GB-Mo" = "${format("%6.2f", ceil(local.terms[local.termsOrdered[0]].terms.pricePerUnit.USD * 100 * 10) / 100)}"
        "3.) 100GB-Mo" = "${format("%6.2f", ceil(local.terms[local.termsOrdered[0]].terms.pricePerUnit.USD * 100 * 100) / 100)}"
        "4.)   1TB-Mo" = "${format("%6.2f", ceil(local.terms[local.termsOrdered[0]].terms.pricePerUnit.USD * 100 * 1000) / 100)}"
        "5.)  50TB-Mo" = "${format("%6.2f", ceil(local.terms[local.termsOrdered[0]].terms.pricePerUnit.USD * 100 * 5000) / 100)}"
      }
      terms = local.terms[local.termsOrdered[0]].terms.description
    }
    ceiling = {
      location = "${local.terms[element(local.termsOrdered, -1)].result.product.attributes.regionCode} ${local.terms[element(local.termsOrdered, -1)].result.product.attributes.location}"
      price = {
        "1.)   1GB-Mo" = "${format("%6.2f", ceil(local.terms[element(local.termsOrdered, -1)].terms.pricePerUnit.USD * 100 * 1) / 100)}"
        "2.)  10GB-Mo" = "${format("%6.2f", ceil(local.terms[element(local.termsOrdered, -1)].terms.pricePerUnit.USD * 100 * 10) / 100)}"
        "3.) 100GB-Mo" = "${format("%6.2f", ceil(local.terms[element(local.termsOrdered, -1)].terms.pricePerUnit.USD * 100 * 100) / 100)}"
        "4.)   1TB-Mo" = "${format("%6.2f", ceil(local.terms[element(local.termsOrdered, -1)].terms.pricePerUnit.USD * 100 * 1000) / 100)}"
        "5.)  50TB-Mo" = "${format("%6.2f", ceil(local.terms[element(local.termsOrdered, -1)].terms.pricePerUnit.USD * 100 * 5000) / 100)}"
      }
      terms = local.terms[element(local.termsOrdered, -1)].terms.description
    }
    home = {
      location = "${local.terms[data.aws_region.current.name].result.product.attributes.regionCode} ${local.terms[data.aws_region.current.name].result.product.attributes.location}"
      price = {
        "1.)   1GB-Mo" = "${format("%6.2f", ceil(local.terms[data.aws_region.current.name].terms.pricePerUnit.USD * 100 * 1) / 100)}"
        "2.)  10GB-Mo" = "${format("%6.2f", ceil(local.terms[data.aws_region.current.name].terms.pricePerUnit.USD * 100 * 10) / 100)}"
        "3.) 100GB-Mo" = "${format("%6.2f", ceil(local.terms[data.aws_region.current.name].terms.pricePerUnit.USD * 100 * 100) / 100)}"
        "4.)   1TB-Mo" = "${format("%6.2f", ceil(local.terms[data.aws_region.current.name].terms.pricePerUnit.USD * 100 * 1000) / 100)}"
        "5.)  50TB-Mo" = "${format("%6.2f", ceil(local.terms[data.aws_region.current.name].terms.pricePerUnit.USD * 100 * 5000) / 100)}"
      }
      terms = local.terms[data.aws_region.current.name].terms.description
    }
  }
}

#output "price_sample" {
#  value = data.aws_pricing_product.storage_standard[data.aws_region.current.name]
#}
