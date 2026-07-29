# Dataset Job Module

## Purpose

The Dataset Job module provisions all infrastructure required to transform a single dataset into another dataset.

It is the smallest reusable execution unit of the Workflows domain.

Workflow modules compose one or more Dataset Jobs to implement complete data pipelines.

---

# Responsibilities

This module is responsible for:

- Provisioning the execution identity (IAM Role).
- Provisioning the execution environment.
- Executing a transformation script.
- Providing logging.
- Managing execution configuration.

The current implementation uses AWS Glue as the execution engine.

---

# Out of Scope

This module does **not**:

- Schedule executions.
- Coordinate multiple jobs.
- Create Glue Workflows.
- Create S3 buckets.
- Create Glue Databases.
- Create Glue Tables.
- Define business transformations.

These responsibilities belong to higher-level workflow modules.

---

# Module Interface

The module is intentionally dataset-oriented rather than infrastructure-oriented.

Instead of exposing AWS implementation details, the module receives the logical datasets involved in the transformation.

Example:

```hcl
module "orders" {
  source = "../commons/dataset_job"

  name = "orders"

  runtime_bucket = module.silver_workflow.runtime_bucket_name

  script_key = "silver/orders.py"

  input_database = module.bronze.database_name
  input_dataset  = "orders_raw"

  output_database = module.silver.database_name
  output_dataset  = "orders"

  runtime = {
    glue_version = "5.0"
    worker_type  = "G.1X"
    workers      = 2
    timeout      = 10
  }
}
```

---

# Design Principles

- One job transforms one dataset.
- Workflows compose multiple Dataset Jobs.
- Infrastructure details remain internal to the module.
- The public interface should remain stable even if the execution technology changes in the future.

---

# Future Evolution

Future versions may support:

- Additional execution engines.
- Job bookmarks.
- Retry policies.
- Notifications.
- Metrics.
- Data quality integrations.
- Execution tags.
- Additional runtime options.

These improvements should not require changes to existing workflow modules.
