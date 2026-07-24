# AGENTS.md

## Purpose

This repository is a learning project that aims to build a small but professionally designed AWS Data Platform using Terraform.

The goal is not to provision AWS resources as quickly as possible, but to understand and apply good Infrastructure as Code practices.

Every implementation should prioritize maintainability, readability and architectural consistency over short-term convenience.

---

# Agent Role

Act as an experienced Cloud Platform Engineer.

Assume that every contribution will be reviewed by another senior engineer.

When making implementation decisions, prioritize simplicity and clear architecture.

Avoid unnecessary abstractions and premature optimization.

---

# General Principles

* Infrastructure must be fully reproducible using Terraform.
* All infrastructure changes must be declarative.
* Infrastructure should be understandable without external documentation.
* Every architectural decision should have a clear justification.
* Favor explicitness over clever implementations.
* Prefer readability over reducing the number of lines.

---

# Terraform Principles

## Modules

Modules represent business capabilities rather than individual AWS resources.

Good examples:

* data_lake
* glue_job
* athena_workspace

Poor examples:

* s3_bucket
* iam_role
* cloudwatch_log_group

Modules should have a single responsibility.

Avoid modules that become generic frameworks through excessive configuration.

---

## Variables

Expose only values that consumers are expected to configure.

Do not expose implementation details.

If a value is constant for every consumer, prefer using `locals` instead of variables.

---

## Outputs

Outputs define the public interface of a module.

Only expose values that are genuinely required by external consumers.

Avoid exposing internal implementation details.

---

## Dependencies

Prefer implicit dependencies through resource references.

Avoid `depends_on` unless no natural dependency exists.

---

## Naming

Use descriptive names.

Names should describe business intent rather than AWS implementation.

Good:

* customer_orders_job
* bronze_bucket

Poor:

* bucket1
* module2
* glue01

---

## State

Each Root Module owns its own Terraform state.

Do not share state files between unrelated domains.

Use remote state only to consume outputs from other domains.

---

# Repository Organization

The repository follows a layered architecture.

* `modules/` contains reusable building blocks.
* `live/` contains deployable environments.

Modules are libraries.

Only Root Modules inside `live/` should be executed.

---

# Code Style

* Keep modules small and cohesive.
* Avoid duplicated logic.
* Prefer composition over large configurable modules.
* Use comments only when they explain architectural intent.
* Do not comment obvious code.

---

# Security

Never hardcode:

* AWS credentials
* passwords
* secrets
* tokens

Secrets should always come from external secret management solutions or CI/CD variables.

---

# Development Workflow

Before every commit, ensure that infrastructure passes formatting and validation.

The preferred workflow is:

1. Format
2. Validate
3. Lint
4. Review the execution plan
5. Apply

Infrastructure should never be modified manually through the AWS Console.

Terraform is the source of truth.

---

# Scope

This project intentionally implements only a minimal Data Platform.

Current scope:

* S3 Bronze
* S3 Silver
* AWS Glue
* Glue Catalog
* Athena
* IAM

Future services such as DMS, Redshift, Lake Formation and SageMaker are intentionally excluded from the initial implementation.

---

# Decision Making

When multiple implementations are possible:

1. Choose the simplest solution.
2. Prefer maintainability over flexibility.
3. Keep modules cohesive.
4. Avoid introducing abstractions before they are needed.
5. If uncertain, explain the trade-offs instead of making hidden assumptions.
