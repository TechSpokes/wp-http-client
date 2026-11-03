# Security Policy

## Supported versions

No version has been released yet. Once releases begin, security fixes go to the latest minor release.

## Reporting a vulnerability

Report vulnerabilities through [GitHub private vulnerability reporting](https://github.com/TechSpokes/wp-http-client/security/advisories/new), by email to `contact@techspokes.com`, or through the [TechSpokes contact page](https://www.techspokes.com/contact/).

Do not file public issues for security reports.

We acknowledge receipt within 72 hours and aim to provide a fix or mitigation plan promptly.

## Scope

This package sends requests through the WordPress HTTP API and inherits its URL validation. Server-side request forgery through DNS rebinding is a known limitation of that validation and cannot be fixed in PHP userland; reports that depend only on it are documented rather than treated as package vulnerabilities.
