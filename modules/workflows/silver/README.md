# Silver Workflow Module

## Purpose

The Silver Workflow module deploys every Dataset Job required to produce the Silver layer.

It represents the deployment unit for all Silver transformations.

Rather than exposing individual Glue Jobs, the module encapsulates the complete implementation of the Silver layer.

---

# Responsibilities

This module is responsible for:

- Provisioning the runtime infrastructure shared by all Silver jobs.
- Deploying every Dataset Job required by the Silver layer.
- Providing a single deployment entry point for the entire workflow.

Current implementation:

- Orders Dataset Job

Future implementations may include additional Dataset Jobs without changing the module interface.

---

# Architecture

```
                Silver Workflow
                       │
        ┌──────────────┴──────────────┐
        │                             │
 Runtime Infrastructure         Dataset Jobs
        │                             │
        │                      ┌──────┴──────┐
        │                      │             │
        │                  Orders      Customers
        │
        └──────────── Shared by all jobs
```

The workflow owns the infrastructure shared across all Dataset Jobs.

Individual jobs are implemented using the reusable `dataset_job` module.

---

# Current Dataset Jobs

| Dataset | Input | Output |
|---------|-------|--------|
| Orders | Bronze `orders_raw` | Silver `orders` |

---

# Runtime Infrastructure

The workflow provisions infrastructure shared by every Dataset Job.

Examples include:

- Runtime S3 bucket
- Lifecycle rules
- Shared execution configuration

Dataset Jobs consume these resources but never create them.

---

# Out of Scope

This module does **not**:

- Create Bronze or Silver buckets.
- Create Glue Databases.
- Create Glue Tables.
- Manage analytics resources.
- Deploy other workflow layers.

Those responsibilities belong to other platform modules.

---

# Design Principles

- The workflow is the deployment unit.
- Dataset Jobs are reusable implementation units.
- Shared runtime infrastructure is provisioned once per workflow.
- Adding a new Dataset Job should only require changes inside this module.

---

# Future Evolution

The module is expected to evolve by adding new Dataset Jobs such as:

- Customers
- Products
- Payments
- Inventory

Scheduling and orchestration may be introduced in future versions without changing the module interface.

Examples include:

- EventBridge
- Glue Workflows
- Step Functions
- External orchestrators