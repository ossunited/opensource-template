<!--
SPDX-FileCopyrightText: Copyright (c) 2025 Broadsage <opensource@broadsage.com>

SPDX-License-Identifier: Apache-2.0
-->

# Security Policy for OSS United

## Overview

At the OSS United, we are committed to ensuring the security and integrity of our open-source projects. We value the contributions of security researchers and the broader community in helping us identify and address vulnerabilities in our software. This document outlines our process for reporting security issues, how we handle disclosures, and our commitment to maintaining secure software for all users.

## Supported Versions

We provide security updates for the following versions of our projects:

| Project Name       | Version        | Supported Until       |
|--------------------|----------------|-----------------------|
| Core        | 2.x            | Ongoing               |
| OpenCore        | 1.x            | End of Life: 2025-12-31 |
| OpenAPI         | 3.x            | Ongoing               |
| OpenAPI         | 2.x            | End of Life: 2024-06-30 |
| OpenSuite  | Latest Release | Ongoing               |

Please ensure you are using a supported version to receive security updates. We recommend upgrading to the latest stable release as soon as possible.

## Reporting a Vulnerability

If you discover a security vulnerability in any OSS United projects, we encourage you to report it to us responsibly. Here’s how:

1. **Contact Us Privately**:
   Please email security vulnerabilities to [security@broadsage.com](mailto:security@broadsage.com). Do not disclose the issue publicly (e.g., on GitHub issues, forums, or social media) until we have had a chance to address it.

2. **What to Include**:
   Provide a detailed description of the vulnerability, including:
   - The affected project and version.
   - Steps to reproduce the issue.
   - Potential impact (e.g., data exposure, privilege escalation).
   - Any suggested fixes or mitigations, if applicable.

3. **Response Expectations**:

- We will acknowledge receipt of your report within 48 hours.
- We aim to provide an initial assessment within 5 business days.
- We will keep you informed of our progress and notify you when the issue is resolved.

## Vulnerability Handling Process

1. **Triage**: Upon receiving a report, our security team will triage the issue to confirm its validity and assess its severity.
2. **Resolution**: We will work on a fix, prioritizing based on the severity and impact of the vulnerability.
3. **Disclosure**: Once a fix is ready, we will release a security update and coordinate with you on disclosure timing (see "Disclosure Policy" below).
4. **Credit**: We are happy to publicly credit you for your discovery (unless you prefer to remain anonymous).

## Disclosure Policy

The OSS United follows a **90-day coordinated disclosure policy**:

- We aim to resolve critical vulnerabilities within 90 days of a report.
- If more time is needed, we will communicate transparently with the reporter and provide updates on our progress.
- Once a fix is released, we will publish a security advisory with details of the vulnerability and credit to the reporter (if desired).
- In cases of active exploitation, we may expedite disclosure to protect users, while still aiming to coordinate with the reporter.

## Security Best Practices

We encourage users and contributors to follow these best practices to enhance security:

- **Keep Software Updated**: Always use the latest supported version of our software.
- **Secure Configurations**: Follow our documentation for secure configuration guidelines.
- **Dependency Management**: Regularly update dependencies and monitor for known vulnerabilities.
- **Contribute Securely**: When contributing code, adhere to our coding standards and ensure your changes do not introduce vulnerabilities.

## Bug Bounty Program

The OSS United currently does not operate a formal bug bounty program. However, we deeply appreciate the efforts of security researchers and may offer recognition, swag, or other forms of gratitude for responsible disclosures at our discretion.

## Contact Information

For all security-related concerns, please contact us at:
📧 [security@broadsage.com](mailto:security@broadsage.com)

For general inquiries or non-security issues, please use our main contact channels listed on our website.

## Acknowledgments

We would like to thank the researchers and contributors who have helped improve the security of our projects.

Thank you for helping us keep the OSS United projects secure!
