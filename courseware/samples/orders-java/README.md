# Orders service (Java)

A small order-taking API: a product catalog, order validation, discounts, and regional sales tax.
It's a Spring Boot 4 web application on Java 21 with an in-memory store, so there's no database to set up.

## Layout

```
pom.xml                         # Spring Boot parent pins every dependency version
mvnw, mvnw.cmd, .mvn/           # Maven Wrapper — no Maven install needed
src/main/java/com/example/orders/
  model/        # Order, OrderLine, Product, CustomerTier, OrderStatus
  pricing/      # DiscountPolicy, TaxCalculator, PriceSummary
  validation/   # OrderValidator and its error codes
  catalog/      # the product catalog
  service/      # OrderService and the order repository
  web/          # REST controllers
src/test/java/com/example/orders/   # JUnit 6 tests, including MockMvc endpoint tests
```

## Build, test, run

```powershell
.\mvnw.cmd test                  # Windows
.\mvnw.cmd spring-boot:run       # http://localhost:8080
```

```bash
./mvnw test                      # macOS / Linux
./mvnw spring-boot:run
```

The wrapper downloads the pinned Maven version on first use; all it needs is a JDK 21 or later.

## Endpoints

| Method | Path | What it does |
|---|---|---|
| `GET` | `/products` | The catalog |
| `GET` | `/orders?status=PENDING` | Orders, optionally filtered by status |
| `GET` | `/orders/{id}` | One order, or 404 |
| `POST` | `/orders` | Place an order: 201 with the priced order, or 400 with error codes |

A request to place an order:

```json
{
  "customerId": "C-1001",
  "customerTier": "SILVER",
  "region": "WA",
  "lines": [ { "sku": "MON-27", "quantity": 2 } ],
  "couponCode": null
}
```

## Pricing in one paragraph

The subtotal is the sum of the lines at catalog prices. `DiscountPolicy` takes off bulk, volume, loyalty,
and coupon discounts. `TaxCalculator` then charges the shipping region's sales tax on what's left
(finance policy FIN-7). Both work in `BigDecimal` to the cent.
