cp4d
====

This role installs [IBM Cloud Pak for Data](https://www.ibm.com/uk-en/products/cloud-pak-for-data) Operator in the target cluster.  Support is available for both CP4D v3.5 (installed into the `cpd-meta-ops` namespace) and CP4D v4.0 (installed into the `ibm-common-services` namespace).

If you are installing CP4D v4 then the [cp4d_hack_worker_nodes](cp4d_hack_worker_nodes.md) role must have been executed during cluster set up to update the cluster's global image pull secret and reload all worker nodes.

The role assumes that you have already installed the IBM Operator Catalog in the target cluster.  This action is performed by the [ibm_catalogs](ibm_catalogs.md) role if you want to use this collection to install the CatalogSource.

CloudPak for Data support comes in two flavours: CP4D v3.5 and CP4D v4.  For users of MAS v8.7 or later only CP4D v4 is supported.  MAS 8.6 with the January 2022 maintenance updates supports both, and earlier version of MAS only support CP4D v3.5.

- CloudPak for Data v3.5 is installed from the IBM Operator Catalog using the `v1.0` channel to the `cpd-meta-ops` namespace.
- CloudPak for Data v4 is installed from the IBM Operator Catalog using the `v2.0` channel to the `ibm-common-services` namespace.

!!! warning
    The credentials to sign-in when deploying CP4D v3.5 are the defaults, which are `admin/password`.  Yes, really!


Role Variables
--------------

### cpd_entitlement_key
Required only if `cpd_version = cpd35`, otherwise unused because in CP4D v4 we have to use the [cp4d_hack_worker_nodes](cp4d_hack_worker_nodes.md) role to prepare the cluster ahead of time by setting up a global image pull secret for CP4D.  Holds your IBM Entitlement key.

- Environment Variable: `CPD_ENTITLEMENT_KEY`
- Default: None

### cpd_primary_storage_class
Required only if `cpd_version = cpd40`, otherwise unused.
Default storage class in CPD v4.0, for IBM Cloud `ibmc-file-gold-gid` can be used.

- Environment Variable: `CPD_STORAGE_CLASS`
- Default Value: None

### cpd_metadata_storage_class
Required only if `cpd_version = cpd40`, otherwise unused.
Default block storage class for `zenCoreMetaDbStorageClass` in CPD v4.0, for IBM Cloud `ibmc-block-gold` can be used.

- Environment Variable: `CPD_METADB_BLOCK_STORAGE_CLASS`
- Default Value: None

### cpd_services_namespace
Only supported if `cpd_version = cpd40`, otherwise unused. For v3.5 support this value is always set to `cpd-meta-ops`.

- Environment Variable: `CPD_SERVICES_NAMESPACE`
- Default Value: `cpd-services`



Example Playbook
----------------

```yaml
- hosts: localhost
  any_errors_fatal: true
  vars:
    cpd_primary_storage_class: ibmc-file-gold-gid
    cpd_metadata_storage_class: ibmc-block-gold
  roles:
    - ibm.mas_devops.cp4d
```

License
-------

EPL-2.0
