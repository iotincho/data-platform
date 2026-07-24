# Architecture

> **Status:** Draft
> This document describes the architectural decisions behind the Terraform Data Platform Lab.
>
> It intentionally progresses from abstract concepts to concrete implementation.
>
> Readers are encouraged to read it sequentially.

---

# Reading Guide

This document is organized from conceptual architecture to implementation details.

1. Architectural Principles
2. Platform Responsibilities
3. Module Contracts
4. Platform Dependencies
5. Repository Organization
6. Root Modules
7. AWS Mapping
8. Data Flow
9. Infrastructure Lifecycle
10. Future Evolution

The objective is to understand **why** the platform is designed this way before looking at **how** it is implemented.

---

# 1. Architectural Principles

The objective of this project is **not** to learn Terraform syntax.

The objective is to learn how to design Infrastructure as Code for a modern cloud-based Data Platform.

Although the platform implemented in this repository is intentionally small, every architectural decision should remain valid if the project grows in the future.

## Guiding Principles

* Infrastructure is fully reproducible using Terraform.
* Infrastructure is described declaratively.
* Modules represent **platform capabilities**, not AWS resources.
* Components have clearly defined ownership and responsibilities.
* Infrastructure should be easy to understand by reading the code.
* Simplicity is preferred over premature abstraction.
* Every module should have a single responsibility.

## Non Goals

This project intentionally avoids enterprise-level complexity.

The first iteration will **not** include:

* AWS DMS
* Kafka
* Redshift
* SageMaker
* Lake Formation
* Multi-account deployments
* Multi-region deployments
* Production networking
* Cost optimization

Those topics may be introduced in future iterations.

---

# 2. Platform Responsibilities

The platform is decomposed according to business responsibilities rather than AWS services.

## Foundation

### Responsibility

Provide the common infrastructure required by every other platform component.

### Owns

* Terraform backend
* Shared tags
* Global configuration
* Common IAM resources (if required)

### Exposes

Platform-wide configuration consumed by other domains.

---

## Data Lake

### Responsibility

Own the lifecycle of analytical datasets.

Responsible for receiving raw data, storing curated datasets and executing ETL processes.

### Owns

* Bronze storage
* Silver storage
* Glue Catalog
* Glue Jobs

### Consumes

* Foundation outputs

### Exposes

* Bronze bucket
* Silver bucket
* Glue Catalog Database

---

## Analytics

### Responsibility

Provide query capabilities over curated datasets.

Analytics should never know how data was ingested or transformed.

It only consumes curated datasets.

### Owns

* Athena Database
* Athena Workgroup

### Consumes

* Data Lake outputs

### Exposes

Query interfaces for analytical workloads.

---

# 3. Module Contracts

Terraform modules should expose small and well-defined interfaces.

Every module should answer the following questions:

* Why does this module exist?
* What responsibility does it own?
* Which inputs does it require?
* Which outputs does it expose?
* Which dependencies does it consume?

---

## Module: data_lake

### Purpose

Provision the storage and metadata infrastructure required by analytical datasets.

### Owns

* Bronze bucket
* Silver bucket
* Glue Catalog

### Inputs

*To be defined.*

### Outputs

*To be defined.*

---

## Module: glue_job

### Purpose

Deploy reusable Glue ETL jobs.

Each Glue Job is responsible for transforming one dataset.

### Owns

* Glue Job
* IAM Role
* CloudWatch Logs

### Inputs

*To be defined.*

### Outputs

*To be defined.*

---

## Module: athena

### Purpose

Provide query capabilities over curated datasets.

### Owns

* Athena Database
* Athena Workgroup

### Inputs

*To be defined.*

### Outputs

*To be defined.*

---

# 4. Platform Dependencies

The platform follows a one-way dependency graph.

```text
Foundation
      │
      ▼
Data Lake
      │
      ▼
Analytics
```

Dependencies represent ownership boundaries.

A domain should never manage infrastructure owned by another domain.

Instead, it should consume exported outputs through Terraform Remote State.

---

# 5. Repository Organization

The repository mirrors the platform architecture.

```text
terraform-data-platform-lab/

├── modules/
│
├── live/
│
├── docs/
│
├── README.md
│
├── AGENTS.md
│
└── ARCHITECTURE.md
```

## modules/

Contains reusable Terraform modules.

Modules are libraries.

They are **not** executed directly.

---

## live/

Contains deployable Root Modules.

Each directory represents an independent Terraform State.

Only directories inside `live/` should execute Terraform commands.

---

## docs/

Additional project documentation.

---

# 6. Root Modules

The initial implementation contains a single development environment.

```text
live/

└── dev/

      foundation/

      data_lake/

      analytics/
```

Each Root Module:

* owns a single Terraform State
* consumes remote outputs from upstream domains
* exposes outputs required by downstream domains

---

# 7. AWS Mapping

AWS services are implementation details of platform capabilities.

| Platform Capability | AWS Services                           |
| ------------------- | -------------------------------------- |
| Foundation          | Terraform Backend, IAM                 |
| Data Lake           | Amazon S3, AWS Glue, Glue Data Catalog |
| Analytics           | Amazon Athena                          |

The architecture should continue making sense even if the underlying cloud services change.

---

# 8. Data Flow

The first iteration implements a single ETL pipeline.

```text
CSV

↓

Bronze (S3)

↓

Glue ETL

↓

Silver (Parquet)

↓

Athena
```

Future datasets should be added by instantiating additional Glue Job modules without requiring architectural changes.

---

# 9. Infrastructure Lifecycle

Infrastructure follows a GitOps-inspired workflow.

```text
Developer

↓

Pull Request

↓

Terraform Format

↓

Terraform Validate

↓

Terraform Plan

↓

Review

↓

Merge

↓

Terraform Apply
```

Terraform is the single source of truth.

Infrastructure must never be modified manually through the AWS Console.

---

# 10. Future Evolution

The following capabilities are intentionally postponed.

* CDC ingestion (AWS DMS)
* Streaming pipelines
* Redshift
* SageMaker
* Lake Formation
* Data Quality
* Observability
* Cost Governance
* Multiple environments
* Separate Terraform Modules repository

The architecture should allow these features to be introduced without significant refactoring.
