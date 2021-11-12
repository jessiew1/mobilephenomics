---
layout: default
title: PMACS AWARE Server
has_children: false
parent: Technical Infrastructure
has_toc: false
nav_order: 2
---
# PMACS AWARE Server
In order to collect passive data, some machine in the cloud needs to be running constantly and minimally preprocessing it for storage. PMACS has set up this machine as a dedicated server called `aware-dev.pmacs.edu`, or simply `aware-dev`.

To access, first make sure you're on the [PMACS VPN](https://www.med.upenn.edu/dart/assets/user-content/documents/pmacs-vpn-mac-os-automated-install-and-configuration-(preferred).pdf), then use ssh:

```shell
ssh -y ttapera@aware-dev.pmacs.edu
```
<!-- TODO Create a project folder on PMACS -->
