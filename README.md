# AWS Pricing Queries

Queries the AWS Pricing API during planning. You're not supposed to write code like this.

## Quick Start

```shell
terraform init
terraform plan
```

<!-- BEGIN_TF_DOCS -->

### Requirements

No requirements.

### Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_aws"></a> [aws](#provider_aws)                      | 5.84.0  |
| <a name="provider_aws.global"></a> [aws.global](#provider_aws.global) | 5.84.0  |

### Modules

No modules.

### Resources

| Name                                                                                                                                   | Type        |
| -------------------------------------------------------------------------------------------------------------------------------------- | ----------- |
| [aws_pricing_product.storage_standard](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/pricing_product) | data source |
| [aws_region.current](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                            | data source |
| [aws_region.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/region)                               | data source |
| [aws_regions.this](https://registry.terraform.io/providers/hashicorp/aws/latest/docs/data-sources/regions)                             | data source |

### Inputs

No inputs.

### Outputs

| Name                                                  | Description |
| ----------------------------------------------------- | ----------- |
| <a name="output_prices"></a> [prices](#output_prices) | n/a         |

<!-- END_TF_DOCS -->
