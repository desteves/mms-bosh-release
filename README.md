# MongoDB Ops Manager BOSH Release

[![Git](https://app.soluble.cloud/api/v1/public/badges/98167c5c-970c-4218-a075-5ef877445f9f.svg?orgId=679096383598)](https://app.soluble.cloud/repos/details/github.com/desteves/mms-bosh-release?orgId=679096383598)  

BOSH release for MongoDB Ops Manager 4.0.x

**THIS IS A STANDALONE INSTANCE WITH NO BACKUPS or HTTPS CONFIGURED, FOR DEV ONLY**

See also the PCF Tile [here](https://github.com/desteves/mongodb-ops-manager-tile) 

## Build

`bosh create-release --json --final --tarball /tmp/mms.tgz | tee /tmp/create.json`

## Run Errand

```
export BOSH_CLIENT=admin
export BOSH_CLIENT_SECRET=`bosh int ./creds.yml --path /admin_password`
bosh -n -e os-bosh login
bosh -e os-bosh -d mongodb-ops-manager run-errand global_owner

## output
# Using environment '10.0.2.2' as client 'admin'

# Using deployment 'mongodb-ops-manager'

# Task 593

# Task 593 | 23:01:36 | Preparing deployment: Preparing deployment (00:00:00)
# Task 593 | 23:01:36 | Running errand: ops_manager/79bc7a43-5562-4af5-814b-8e400401b9e2 (0) (00:00:01)
# Task 593 | 23:01:37 | Fetching logs for ops_manager/79bc7a43-5562-4af5-814b-8e400401b9e2 (0): Finding and packing log files (00:00:01)

# Task 593 Started  Sun Oct  7 23:01:36 UTC 2018
# Task 593 Finished Sun Oct  7 23:01:38 UTC 2018
# Task 593 Duration 00:00:02
# Task 593 done

# Instance   ops_manager/79bc7a43-5562-4af5-814b-8e400401b9e2
# Exit Code  0
#Stdout     Waiting up to 2 minutes for HTTP(S) to load...
########################################
#          Registering admin user (username: root, password: rootroot12345^)

# 1 errand(s)

# Succeeded

```







