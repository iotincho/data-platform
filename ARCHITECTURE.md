# Architecture

## 1. Vision

This repository implements a production-inspired AWS Data Platform using Terraform.

The primary objective is not simply provisioning cloud infrastructure, but learning how modern cloud platforms are designed, organized and evolved.

The business scope intentionally remains small while the engineering practices remain close to what would be expected in a real production environment.

The platform follows several core principles:

- Infrastructure as Code
- Independent platform domains
- Capability-driven architecture
- Reusable modules
- Explicit contracts
- Incremental evolution

Every architectural decision should prioritize long-term maintainability over short-term convenience.

---

# 2. Design Principles

## Capability-driven Architecture

Terraform modules represent **platform capabilities**, not individual AWS resources.

The intention is to model concepts that exist in the platform instead of exposing cloud provider implementation details.

Examples of platform capabilities include:

- Foundation
- Data Layer
- Query Workgroup
- Workflow (future)

Consumers should interact with these capabilities rather than directly provisioning AWS resources.

This approach provides:

- cleaner APIs
- reduced coupling
- better readability
- easier future evolution

---

## Independent Platform Domains

The platform is divided into independent infrastructure domains.

Each domain owns:

- its own responsibilities
- its own Terraform State
- its own deployment lifecycle

Domains communicate only through explicit contracts.

No domain should depend on another domain's internal implementation.

---

## Infrastructure as Code

Terraform is the single source of truth.

Infrastructure must never be modified manually through the AWS Console.

Every infrastructure change should be represented by code and reviewed before deployment.

---

## Incremental Evolution

Infrastructure is introduced only when required.

The platform intentionally avoids implementing future requirements before they become necessary.

This keeps the platform:

- easier to understand
- easier to maintain
- cheaper to operate
- simpler to evolve

---

## Encapsulation

Reusable modules encapsulate AWS implementation details.

Root Modules should orchestrate platform capabilities rather than implement infrastructure logic.

Whenever possible:

- complexity belongs inside reusable modules
- orchestration belongs inside Root Modules

---

## Stable Public APIs

Reusable modules should expose small, stable interfaces.

New functionality should be introduced through backwards-compatible changes whenever possible.

Module responsibilities should remain focused.

If a module begins accumulating unrelated responsibilities, it should be reconsidered, renamed or decomposed.

---

# 3. Platform Domains

The platform is organized into independent infrastructure domains.

Current domains include:

- Foundation
- Data Lake
- Analytics

Future domains may include:

- Workflows
- Monitoring
- Security

Current dependency graph:

```text
                 Foundation
                 /        \
                /          \
               ▼            ▼
        Data Lake      Analytics
```

Foundation provides shared capabilities.

Data Lake and Analytics consume Foundation independently.

Neither domain depends directly on the other.

This separation allows each domain to evolve independently while communicating through explicit contracts.

---

# 4. Repository Organization

The repository mirrors the platform architecture.

```text
terraform-data-platform-lab/

├── live/
│   ├── bootstrap/
│   └── dev/
│       ├── foundation/
│       ├── data_lake/
│       └── analytics/
│
├── modules/
│   ├── data_layer/
│   └── workgroup/
│
├── docs/
│   └── datasets/
│       └── schemas/
│
├── scripts/              # future
│
├── README.md
├── AGENTS.md
└── ARCHITECTURE.md
```

---

## Root Modules

Root Modules live under `live/`.

Each Root Module represents one deployable platform domain.

Responsibilities:

- own a Terraform State
- orchestrate reusable modules
- expose outputs consumed by downstream domains

Root Modules should remain small.

Their purpose is orchestration rather than infrastructure implementation.

---

## Reusable Modules

Reusable modules live under `modules/`.

Modules represent platform capabilities.

Examples:

- data_layer
- workgroup

Modules are libraries.

They should never be executed directly.

Their responsibility is encapsulating AWS implementation details behind stable interfaces.

---

## Documentation

Project documentation lives under `docs/`.

Dataset contracts are also part of the documentation.

Terraform consumes those contracts rather than defining them directly.

This keeps infrastructure and business definitions clearly separated.

# 5. Foundation

## Responsibility

Foundation provides the shared capabilities required by every other platform domain.

Its purpose is not to centralize infrastructure, but to own only the components that are truly common across the platform.

Every downstream domain should be able to assume that Foundation already exists.

---

## Current Responsibilities

The first iteration intentionally keeps Foundation minimal.

Current capabilities include:

- Platform-wide naming conventions
- Common resource tags
- Shared platform configuration

Foundation intentionally avoids owning business-specific infrastructure.

---

## Future Responsibilities

Foundation should evolve only when another platform domain requires new shared capabilities.

Examples include:

- VPC
- Private Subnets
- Security Groups
- Route Tables
- NAT Gateways
- VPC Endpoints
- Shared KMS Keys
- Shared IAM Roles

These capabilities should never be implemented proactively.

They should appear naturally as the platform grows.

---

## Owns

Foundation owns:

- shared platform configuration
- resource naming conventions
- common tags

---

## Consumes

Foundation depends only on the Terraform backend created during the Bootstrap stage.

It has no dependency on any business domain.

---

## Exposes

Foundation exposes platform-wide configuration through Terraform Remote State.

Typical outputs include:

- project_name
- environment
- resource_name_prefix
- common_tags

These outputs form the public contract consumed by downstream domains.

---

# 6. Data Lake

## Responsibility

The Data Lake is responsible for publishing datasets.

It owns the physical storage of analytical data together with the metadata required for consumers to discover those datasets.

The Data Lake hides AWS implementation details behind reusable platform capabilities.

---

## Current Capabilities

The current implementation contains two layers:

- Bronze
- Silver

Each layer is implemented through the reusable **Data Layer** module.

---

## Data Layer

A Data Layer represents a reusable platform capability.

Internally it encapsulates:

- one S3 Bucket
- one Glue Catalog Database
- one or more Glue Catalog Tables

Consumers never provision those resources individually.

Instead they instantiate a Data Layer.

Example:

```text
Bronze Layer

↓

Bucket

Glue Database

Glue Tables
```

The same abstraction is reused for:

- Bronze
- Silver

and later may also be reused for:

- Gold

---

## Dataset Contracts

Dataset definitions do not live inside Terraform.

Instead, every dataset is defined through an external contract.

Current location:

```text
docs/

└── datasets/

    └── schemas/

        ├── bronze/

        └── silver/
```

Each dataset schema describes:

- dataset name
- layer
- storage format
- columns
- partition keys
- documentation

Terraform consumes these contracts to provision Glue Catalog resources.

This establishes the schema files as the single source of truth for dataset definitions.

---

## Owns

The Data Lake owns:

- Bronze Layer
- Silver Layer
- S3 Buckets
- Glue Catalog Databases
- Glue Catalog Tables

---

## Consumes

The Data Lake consumes:

- Foundation outputs

using Terraform Remote State.

---

## Exposes

The Data Lake publishes only its public contract.

Typical outputs include:

- bucket names
- bucket ARNs
- bucket URIs
- Glue database names
- Glue table names

Consumers should never depend on internal implementation details.

---

# 7. Analytics

## Responsibility

Analytics provides environments where consumers execute SQL queries against published datasets.

Analytics owns query execution infrastructure.

It intentionally does **not** own datasets.

---

## Current Capability

The current implementation introduces one reusable capability:

**Workgroup**

A Workgroup represents a complete Athena query environment.

---

## Workgroup

Internally a Workgroup encapsulates:

- Athena Workgroup
- Results Bucket

Future versions may also encapsulate:

- lifecycle policies
- encryption customization
- IAM policies
- named queries
- query limits
- engine configuration

Consumers instantiate Workgroups instead of configuring Athena resources directly.

Example:

```text
Analytics Workgroup

↓

Athena Workgroup

↓

Results Bucket
```

---

## Why Analytics does not depend on the Data Lake

Although Athena queries datasets published by the Data Lake, there is no deployment dependency between these domains.

Athena discovers datasets dynamically through Glue Catalog during query execution.

The Workgroup only defines **how** queries execute.

Glue defines **what** datasets exist.

IAM defines **who** may execute those queries.

This separation keeps the platform loosely coupled.

Current dependency graph:

```text
Foundation
├── Data Lake
└── Analytics

Runtime

Athena
↓

Glue Catalog
↓

S3
```

Notice that the interaction between Analytics and the Data Lake happens at runtime rather than during infrastructure deployment.

---

## Owns

Analytics owns:

- Athena Workgroups
- Results Buckets

---

## Consumes

Analytics consumes only:

- Foundation outputs

using Terraform Remote State.

---

## Exposes

Analytics exposes:

- workgroup names
- results bucket names
- results bucket ARNs
- results bucket URIs

These outputs represent the public contract of the Analytics domain.

---

# 8. Future Domains

The current platform intentionally stops after Analytics.

Future platform capabilities are expected to grow naturally as new requirements appear.

## Workflows

The Workflow domain will orchestrate business pipelines.

Rather than representing individual Glue Jobs, Workflows will represent complete business processes.

Examples include:

- Bronze ingestion
- Bronze → Silver transformation
- Silver → Gold aggregation
- Feature generation for Machine Learning

A Workflow may internally orchestrate multiple Glue Jobs while exposing a single platform capability.

---

## Monitoring

Future monitoring capabilities may include:

- CloudWatch Dashboards
- Metrics
- Alerts
- Centralized Logging
- Operational Dashboards

---

## Security

Future security capabilities may include:

- IAM policies
- Lake Formation
- KMS
- Secrets Manager
- Cross-account access

These capabilities intentionally remain outside the scope of the current iteration.

# 9. Infrastructure Lifecycle

The platform follows a two-stage provisioning model.

This approach solves Terraform's bootstrap problem while allowing every platform domain to evolve independently.

---

## Stage 1 — Bootstrap

Bootstrap is a special Root Module.

It is executed only once using a **local Terraform backend**.

Its only responsibility is provisioning the infrastructure required by every other Root Module.

Current responsibilities include:

- Terraform State Bucket
- State Bucket Versioning

Conceptually:

```text
Local Backend

↓

Bootstrap

↓

Terraform State Bucket
```

Once Bootstrap completes successfully, every subsequent Root Module uses the remote backend.

Bootstrap is no longer part of the normal deployment lifecycle.

---

## Stage 2 — Platform Provisioning

After the backend exists, platform domains can be provisioned independently.

Current deployment graph:

```text
                 Bootstrap
                      │
                      ▼
                 Foundation
                 /        \
                /          \
               ▼            ▼
        Data Lake      Analytics
```

Each Root Module:

- owns an independent Terraform State
- consumes Foundation outputs through Terraform Remote State
- exposes only its public contract
- can evolve independently

This minimizes coupling between platform domains while preserving clear interfaces.

---

## Terraform States

Each platform domain owns its own state.

Example:

```text
bootstrap.tfstate

foundation.tfstate

data_lake.tfstate

analytics.tfstate
```

This separation provides:

- isolated deployments
- independent evolution
- reduced blast radius
- simpler reviews
- clearer ownership

Terraform Remote State is used only to consume public outputs.

Internal implementation details must never be accessed across domains.

---

# 10. Deployment Workflow

The platform follows a GitOps-inspired workflow.

The objective is to validate infrastructure before deployment while keeping Terraform as the single source of truth.

Target workflow:

```text
Developer

↓

Pre-Commit

↓

Pull Request

↓

CI Validation

↓

Terraform Plan

↓

Review

↓

Merge

↓

Terraform Apply
```

---

## Local Validation

Before creating a Pull Request, developers should validate infrastructure locally.

Expected checks include:

- terraform fmt
- terraform validate
- tflint
- documentation validation
- additional quality checks as the platform evolves

The goal is preventing invalid infrastructure from reaching the repository.

---

## Continuous Integration

The CI pipeline should validate every infrastructure change.

Typical responsibilities include:

- formatting
- validation
- linting
- Terraform Plan
- artifact generation

The CI pipeline validates infrastructure.

It does not own deployment decisions.

---

## Continuous Deployment

Infrastructure deployment should occur only after code review.

Terraform Apply should always execute from reviewed infrastructure code.

Manual infrastructure changes through the AWS Console are considered outside the platform workflow.

---

# 11. Architecture Decision Log

## AD-001 — Bootstrap uses a local backend

**Decision**

Bootstrap is implemented as an independent Root Module using a local Terraform backend.

**Reason**

Terraform cannot provision the infrastructure required by its own remote backend.

---

## AD-002 — Foundation owns shared platform capabilities

**Decision**

Foundation represents shared platform capabilities rather than AWS infrastructure.

**Reason**

Avoid creating a central repository of unrelated resources.

Foundation should evolve only when new shared capabilities become necessary.

---

## AD-003 — Networking is intentionally postponed

**Decision**

Networking is not implemented during the first platform iteration.

**Reason**

Current platform capabilities do not require private networking.

Infrastructure should be introduced only when justified by downstream requirements.

---

## AD-004 — Modules represent platform capabilities

**Decision**

Reusable Terraform modules represent platform capabilities rather than individual AWS resources.

Examples include:

- Data Layer
- Workgroup

**Reason**

Platform capabilities evolve independently from cloud provider implementation details.

This produces cleaner APIs and better encapsulation.

---

## AD-005 — Dataset contracts live outside Terraform

**Decision**

Dataset definitions are stored under:

```text
docs/datasets/schemas/
```

Terraform consumes those definitions.

Terraform never duplicates dataset schemas.

**Reason**

Dataset contracts become the single source of truth.

Infrastructure remains responsible only for implementation.

---

## AD-006 — Analytics is independent from the Data Lake

**Decision**

Analytics does not depend on the Data Lake during infrastructure deployment.

Athena discovers datasets dynamically through Glue Catalog during query execution.

**Reason**

Maintain a clear separation between dataset publication and query execution.

Platform domains remain independently deployable.

---

## AD-007 — Each platform domain owns an independent Terraform State

**Decision**

Every Root Module owns its own Terraform State.

Domains communicate only through Terraform Remote State outputs.

**Reason**

Independent deployment.

Reduced coupling.

Smaller blast radius.

Clear ownership boundaries.

---

## AD-008 — Dataset registration is explicit

**Decision**

Datasets are explicitly registered by Root Modules.

Automatic discovery using `fileset()` is intentionally postponed.

**Reason**

Explicit registration improves readability during the early stages of the project.

Automation can be introduced later without changing the architecture.

---

# 12. Future Improvements

The following ideas have been intentionally postponed.

They are expected to appear naturally as the platform evolves.

## Platform

- Shared backend configuration (`backend.hcl`)
- Additional environments
- Production deployment pipeline
- Monitoring domain
- Security domain

---

## Data Lake

- Automatic dataset discovery
- Gold Layer
- Additional dataset formats
- Glue Crawlers (if justified)
- Data Quality validation
- Great Expectations integration

---

## Analytics

- Lifecycle policies for results buckets
- Named Queries
- Query limits
- IAM integration
- Lake Formation permissions
- Multiple Workgroups

---

## Developer Experience

- GitHub Actions
- Pre-Commit Hooks
- Wrapper scripts
- Development automation
- Documentation generation

---

# Closing Notes

This architecture intentionally favors simplicity over completeness.

The platform should evolve incrementally as new requirements emerge.

New capabilities should be introduced only when they provide clear value to downstream domains.

Whenever possible:

- domains should remain independent;
- reusable modules should represent platform capabilities;
- Terraform should remain the single source of truth.

These principles guide every architectural decision within the project.