# Silver Dataset Workflow: Orders

## Purpose

The Orders Silver Workflow transforms the raw `orders_raw` dataset from the Bronze layer into the curated `orders` dataset in the Silver layer.

The resulting dataset is optimized for analytical workloads by applying schema validation, data normalization, type conversion, and format optimization.

This workflow represents the first transformation stage of the platform and defines the contract for producing the Silver Orders dataset.

---

# Business Context

The platform receives raw order data in CSV format from external systems.

The ingestion process is intentionally outside the scope of this project. Therefore, the workflow assumes that the raw dataset is already available in the Bronze layer.

The responsibility of this workflow begins once the Bronze dataset is available.

---

# Inputs

Dataset:

- `orders_raw`

Layer:

- Bronze

Format:

- CSV

Schema:

- `docs/datasets/schemas/bronze/orders_raw.json`

---

# Outputs

Dataset:

- `orders`

Layer:

- Silver

Format:

- Parquet

Schema:

- `docs/datasets/schemas/silver/orders.json`

---

# Processing Steps

The workflow performs the following logical operations:

1. Read the Bronze dataset.
2. Validate the expected schema.
3. Convert fields to their target data types.
4. Normalize date and timestamp values.
5. Remove invalid records.
6. Write the resulting dataset as Parquet.
7. Register or update the metadata required by the analytics layer.

These steps describe the expected behavior of the workflow rather than its implementation.

---

# Data Quality Rules

The workflow is expected to guarantee that the produced dataset satisfies the Silver schema.

Typical validation rules include:

- Required columns must exist.
- Mandatory fields cannot be null.
- Data types must match the target schema.
- Invalid records must not be written to the Silver dataset.

Additional validation rules may be incorporated as the platform evolves.

---

# Infrastructure Responsibilities

The platform is responsible for providing the infrastructure required to execute this workflow.

The implementation is expected to include resources such as:

- Workflow orchestration
- ETL execution environment
- IAM permissions
- Logging
- Temporary storage when required

The specific AWS services used to implement these responsibilities are considered an infrastructure concern and are documented separately.

---

# Runtime Flow

```
orders_raw (Bronze CSV)
        │
        ▼
Read Dataset
        │
        ▼
Validate Schema
        │
        ▼
Transform Data
        │
        ▼
Write Parquet
        │
        ▼
orders (Silver)
```

---

# Failure Conditions

The workflow must fail if:

- The input dataset cannot be found.
- The input schema is invalid.
- The output dataset cannot be written.
- Required infrastructure is unavailable.

A failed execution must never produce a partially written Silver dataset.

---

# Future Evolution

The current implementation is intentionally simple.

Future versions may introduce:

- Multiple transformation stages
- Data quality reports
- Incremental processing
- Partition-aware transformations
- Workflow orchestration
- Notifications and monitoring

These improvements should not modify the contract defined by this document.