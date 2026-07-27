# DATASETS.md

> **Status:** Draft
>
> This document defines how datasets are described within the platform.
>
> Rather than documenting individual datasets, this document specifies the contract that every dataset must follow.
>
> Each dataset is described through one or more JSON schema files, one for each Data Lake layer.

---

# Purpose

The Data Platform is driven by **dataset contracts**.

Each dataset is represented by a JSON schema that defines:

* dataset metadata
* storage format
* partitioning strategy
* column definitions
* documentation

Infrastructure components consume these contracts to build the platform.

Examples include:

* AWS Glue Catalog
* AWS Glue Jobs
* Great Expectations
* Documentation
* Integration tests

The schema definition is therefore the **single source of truth** for the technical representation of every dataset.

---

# Directory Structure

```text
docs/

└── datasets/

    ├── DATASETS.md

    └── schemas/

        ├── bronze/

        │     orders.json

        │     ...

        │
        ├── silver/

        │     orders.json

        │     ...

        │
        └── gold/

              ...
```

Each layer contains one schema file per dataset.

The same dataset may exist in multiple layers with different schemas.

For example:

```text
schemas/

    bronze/

        orders.json

    silver/

        orders.json
```

These files describe different stages of the same dataset lifecycle.

---

# Dataset Lifecycle

Every dataset evolves through the Data Lake layers.

## Bronze

Purpose:

Store data exactly as received from the source system.

Characteristics:

* Immutable
* Raw format
* No business transformations
* Operational metadata may be added
* Closely matches the source schema

Typical formats:

* CSV
* JSON
* Avro

---

## Silver

Purpose:

Provide a clean, standardized and analytics-ready dataset.

Characteristics:

* Typed columns
* Normalized values
* Validated records
* Derived fields
* Suitable for analytical queries

Typical formats:

* Apache Parquet

---

## Gold

Purpose:

Provide business-oriented datasets optimized for reporting and analytics.

Characteristics:

* Aggregated data
* Business metrics
* KPIs
* Dimensional models
* Feature-ready datasets

Gold is intentionally out of scope for the first iteration of this project.

---

# Schema Contract

Every schema file must follow the same structure.

Top-level fields:

| Field          | Description                  |
| -------------- | ---------------------------- |
| dataset        | Dataset name                 |
| layer          | Bronze, Silver or Gold       |
| description    | Human-readable description   |
| format         | Physical storage format      |
| partition_keys | Partition columns (optional) |
| columns        | Column definitions           |

---

## Column Definition

Every column must contain:

| Field       | Description                     |
| ----------- | ------------------------------- |
| name        | Column name                     |
| type        | Logical data type               |
| nullable    | Whether NULL values are allowed |
| description | Human-readable description      |

Example:

```json
{
  "name": "order_id",
  "type": "string",
  "nullable": false,
  "description": "Unique order identifier."
}
```

---

# Design Principles

Dataset contracts should be:

* Human readable
* Machine readable
* Version controllable
* Independent from Terraform
* Independent from AWS

The schema files define the data contract.

Cloud infrastructure should consume these contracts rather than redefining them.

---

# Future Integrations

The same schema contracts are expected to be reused by additional platform components.

Potential consumers include:

* AWS Glue Catalog generation
* Glue ETL jobs
* Great Expectations
* Data quality validation
* Automated documentation
* Schema compatibility testing

Keeping every component aligned with the same schema definition avoids duplication and establishes a single source of truth for the platform.

---

# Current Datasets

The first project iteration includes a single dataset.

| Dataset | Bronze | Silver |   Gold  |
| ------- | :----: | :----: | :-----: |
| Orders  |    ✓   |    ✓   | Planned |

Additional datasets will follow the same contract and require no architectural changes.
