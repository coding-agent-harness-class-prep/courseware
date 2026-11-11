# Changelog

All notable changes to the Orders service are recorded here.

## [Unreleased]

### Added

- `POST /orders/{id}/cancel` cancels a pending order; any other status gets 409 Conflict.

## [1.0.0]

### Added

- Product catalog and order creation endpoints.
- Order validation: customer, region, lines, quantities, and known SKUs.
- Pricing: bulk, volume, loyalty, and coupon discounts, plus regional sales tax.
