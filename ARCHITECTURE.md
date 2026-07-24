## Foundation

### Responsibility

Provide the shared platform capabilities required by every other platform domain.

Foundation is responsible for defining the common infrastructure and conventions upon which the rest of the platform is built.

Its purpose is **not** to centralize infrastructure, but to own only the components that are truly shared across domains.

### Current Responsibilities

The first iteration intentionally keeps Foundation minimal.

It currently owns:

* Platform-wide naming conventions
* Common resource tags
* Shared platform configuration

### Future Responsibilities

Foundation should evolve only when another platform domain requires new shared capabilities.

Examples include:

* VPC
* Private Subnets
* Security Groups
* VPC Endpoints
* Shared KMS Keys

These capabilities will **not** be implemented proactively.

They will be introduced only when a downstream component requires them.

### Owns

* Shared platform conventions
* Shared platform configuration

### Consumes

Foundation does not depend on any business domain.

It only depends on the Terraform remote backend created during the bootstrap process.

### Exposes

Platform-wide configuration consumed by downstream domains.

Typical outputs include:

* project name
* environment
* common tags

---

# 5. Repository Organization

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
│
├── docs/
│
├── README.md
├── AGENTS.md
└── ARCHITECTURE.md
```

## live/bootstrap

Bootstrap is a special Root Module.

It exists solely to solve the Terraform bootstrapping problem.

Initially it uses a **local Terraform backend** in order to provision the infrastructure required by every other Root Module.

Once the remote backend exists, Bootstrap is no longer part of the normal deployment workflow.

Its only responsibility is creating the infrastructure that enables remote Terraform state.

## live/dev

Contains deployable Root Modules for the development environment.

Each Root Module:

* owns an independent Terraform State
* exposes only the outputs required by downstream domains
* consumes upstream outputs using Terraform Remote State

## modules

Contains reusable Terraform modules.

Modules represent **platform capabilities**, not AWS resources.

Modules are libraries and should never be executed directly.

Only Root Modules inside `live/` execute Terraform.

---

# 9. Infrastructure Lifecycle

The platform follows a two-stage provisioning model.

## Stage 1 — Bootstrap

Bootstrap is executed once using a local Terraform backend.

Its responsibility is to provision the infrastructure required by the remote Terraform backend.

```text
Local Backend

↓

Bootstrap

↓

Terraform State Bucket
```

Once completed, every subsequent Root Module uses the remote backend.

---

## Stage 2 — Platform Provisioning

After the backend exists, the platform can be deployed incrementally.

```text
Foundation

↓

Data Lake

↓

Analytics
```

Each Root Module:

* owns its own Terraform State
* consumes upstream outputs through Remote State
* can evolve independently

---

## Deployment Workflow

Infrastructure changes follow a GitOps-inspired workflow.

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

# Foundation Evolution

Foundation is intentionally designed to evolve incrementally.

New shared infrastructure should only be introduced when required by downstream platform domains.

For example:

```text
Current Foundation

↓

Tags

Naming

Shared Configuration
```

Future requirements may naturally evolve Foundation into:

```text
Foundation

↓

Networking

↓

Security

↓

Shared Encryption

↓

Platform Services
```

The architecture intentionally avoids implementing these capabilities before they are needed.

This keeps the platform simple while allowing future growth without major architectural changes.

# Architecture Decision Log

## AD-001

Bootstrap is implemented as an independent Root Module using a local backend.

Reason:
Terraform cannot provision its own remote backend.

---

## AD-002

Foundation represents shared platform capabilities, not AWS infrastructure.

Reason:
Avoid centralizing unrelated resources.

---

## AD-003

Networking is intentionally postponed until a downstream component requires it.

Reason:
Avoid premature infrastructure.