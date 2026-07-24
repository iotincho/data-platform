# Terraform Data Platform Lab

## Overview

This project is a hands-on laboratory to learn how to design and manage cloud infrastructure for a modern data platform using Terraform and AWS.

Rather than focusing on individual AWS services, the goal is to understand how to structure Infrastructure as Code for a real-world project: modular design, state management, reusable components, deployment workflows, and infrastructure ownership.

The project intentionally keeps the business problem small while applying production-grade engineering practices.

---

# Problem Statement

A company receives a CSV file containing daily sales data.

The data must be ingested into a Data Lake, curated into an analytics-ready format, and exposed to analysts for querying.

Although the current requirement is simple, the solution should be designed so that additional data pipelines can be added in the future without requiring architectural changes.

---

# Objectives

The project provisions the minimum infrastructure required to support a simple ETL workflow while exposing the core concepts of Terraform.

The resulting platform should:

* Store raw data in a Bronze layer.
* Process the data using AWS Glue.
* Store curated data in a Silver layer.
* Make curated data queryable through Amazon Athena.
* Follow Infrastructure as Code best practices.

---

# Learning Goals

This repository is primarily a learning project.

It is intended to provide hands-on experience with:

* Terraform project organization.
* Infrastructure modularization.
* Remote state management.
* Environment separation.
* CI/CD for infrastructure.
* Infrastructure validation and linting.
* AWS services commonly used in modern data platforms.

The emphasis is on understanding architectural decisions rather than simply provisioning cloud resources.

---

# Initial Architecture

The first iteration implements a single ETL pipeline.

```
CSV

↓

S3 Bronze

↓

AWS Glue ETL

↓

S3 Silver (Parquet)

↓

Amazon Athena
```

The architecture should remain extensible so that additional datasets or pipelines can be introduced later without redesigning the infrastructure.

---

# Project Scope

## Included

* Terraform modules
* AWS S3
* AWS Glue
* AWS Glue Data Catalog
* Amazon Athena
* IAM Roles and Policies
* Remote Terraform State
* Pre-commit validation
* CI/CD pipeline
* Development environment

## Out of Scope

The following technologies are intentionally excluded from the first iteration:

* AWS DMS
* Kafka / Streaming ingestion
* Redshift
* SageMaker
* Lake Formation
* Multi-account deployments
* Multi-region deployments
* Production-grade networking
* Cost optimization

These features may be introduced in future iterations once the core architecture is complete.

---

# Engineering Principles

This project follows a few guiding principles:

* Infrastructure is fully reproducible through Terraform.
* Infrastructure should be modular and reusable.
* Modules represent business capabilities rather than individual AWS resources.
* Infrastructure ownership should be clearly separated.
* Simplicity is preferred over premature abstraction.
* The project should remain small enough to be completed in a few days while remaining extensible.

---

# Success Criteria

The project is considered successful when it can:

* Provision the complete infrastructure from scratch.
* Destroy and recreate the infrastructure consistently.
* Add a new ETL pipeline with minimal changes.
* Serve as a foundation for future experiments involving larger data platforms and MLOps workloads.
