# Changelog

All notable changes to the Orders service are recorded here.

## [Unreleased]

### Added

- Order validation rejects a line with more than 999 units (`ORD006`), the warehouse pick limit.

## [1.0.0]

### Added

- Product catalog and order creation endpoints.
- Order validation: customer, region, lines, quantities, and known SKUs.
- Pricing: bulk, volume, loyalty, and coupon discounts, plus regional sales tax.
