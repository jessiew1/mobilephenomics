---
layout: default
title: PMACS AWARE Server
has_children: false
parent: Technical Infrastructure
has_toc: false
nav_order: 1
---

# PMACS AWARE Server

In order to collect the passive sensor data from mobile devices, some machine in the cloud needs to be running constantly and minimally preprocessing it for storage. PMACS has set up this machine as a dedicated server called `aware-prd.pmacs.upenn.edu`, or simply `aware-prd`.

To access, first make sure you're on the [PMACS VPN](https://www.med.upenn.edu/dart/assets/user-content/documents/pmacs-vpn-mac-os-automated-install-and-configuration-(preferred).pdf), then use `ssh`:

```shell
ssh -y username@aware-prd.pmacs.upenn.edu
```
<!-- TODO Create a project folder on PMACS -->

The PHP files that manage the app are generally found in `/var/www/html/application`. You can always check the logs for up to date runtime information in `/var/log/httpd`. Generally,
the AWARE app consists of a database, a backend, and a frontend. The database we chose is [MariaDB](https://mariadb.com/), but is effectively identical to MySQL. The backend, as mentioned,
is a PHP web application, and the frontend is the AWARE dashboard. There's not much web app programming experience in PennLINC, so we outsourced our
knowledge.

Usually, you should reach out to Rachel Rawlings from PMACS for access & permissions to `aware-prd`: <a href="mailto:rrache@upenn.edu">rrache@upenn.edu</a>

You should also flag the PMACS database team: <a href="mailto:pmacs-sys-db@lists.upenn.edu">pmacs-sys-db@lists.upenn.edu</a>

For help with the AWARE app itself, reach out to Garrick Sherman from Lyle Ungar's group: <a href="mailto:garricks@sas.upenn.edu">garricks@sas.upenn.edu</a>

# Accessing MariaDB Databases

Log in to PMACS and access the database password like so: 
`grep password /var/www/html/application/config/database.php`

You can then access the database with: 
`mariadb –h localhost –u awareuser –p`

Then when prompted with a password, paste in the password you copied.

You can open a database from a certain participant with all their information/responses like this: 

```shell
use Mehta_26; # example dataset
show tables;
select * from esms;
```