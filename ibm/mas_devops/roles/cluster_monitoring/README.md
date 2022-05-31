cluster_monitoring
==================

Configure both cluster monitoring and user workload cluster monitoring with persistant storage.

Role Variables
--------------
### prometheus_retention_period
Adjust the retention period for Prometheus metrics, only used when both `prometheus_storage_class` and `prometheus_alertmgr_storage_class` are set.

- Optional
- Environment Variable: `PROMETHEUS_RETENTION_PERIOD`
- Default Value: `15d`

### prometheus_storage_class
Declare the storage class for Prometheus' metrics data persistent volume.

- **Required** unless working with OCP on IBMCloud ROKS
- Environment Variable: `PROMETHEUS_STORAGE_CLASS`
- Default Value: Defaults to `ibmc-block-gold` if the storage class is available in the cluster.

### prometheus_storage_size
Adjust the size of the volume used to store metrics, only used when both `prometheus_storage_class` and `prometheus_alertmgr_storage_class` are set.

- Optional
- Environment Variable: `PROMETHEUS_STORAGE_SIZE`
- Default Value: `300Gi`

### prometheus_alertmgr_storage_class
Declare the storage class for AlertManager's persistent volume.

- **Required** unless working with OCP on IBMCloud ROKS
- Environment Variable: `PROMETHEUS_ALERTMGR_STORAGE_CLASS`
- Default Value: Defaults to `ibmc-file-gold-gid` if the storage class is available in the cluster.

### prometheus_alertmgr_storage_size
Adjust the size of the volume used by AlertManager, only used when both `prometheus_storage_class` and `prometheus_alertmgr_storage_class` are set.

- Optional
- Environment Variable: `PROMETHEUS_ALERTMGR_STORAGE_SIZE`
- Default Value: `20Gi`

### prometheus_userworkload_retention_period
Adjust the retention period for User Workload Prometheus metrics, this parameter applies only to the User Workload Prometheus instance.

- Optional
- Environment Variable: `PROMETHEUS_USERWORKLOAD_RETENTION_PERIOD`
- Default Value: `15d`

### prometheus_userworkload_storage_class
Declare the storage class for User Workload Prometheus' metrics data persistent volume.

- Optional
- Environment Variable: `PROMETHEUS_USERWORKLOAD_STORAGE_CLASS`
- Default Value: `PROMETHEUS_STORAGE_CLASS`

### prometheus_userworkload_storage_size
Adjust the size of the volume used to store User Workload metrics.

- Optional
- Environment Variable: `PROMETHEUS_USERWORKLOAD_STORAGE_SIZE`
- Default Value: `300Gi`


Example Playbook
----------------

```yaml
- hosts: localhost
  vars:
    prometheus_storage_class: "ibmc-block-gold"
    prometheus_alertmgr_storage_class: "ibmc-file-gold-gid"
  roles:
    - ibm.mas_devops.cluster_monitoring
```


Tekton Task
-----------
Start a run of the **mas-devops-cluster-monitoring** Task as below, you must have already prepared the namespace:

```
cat <<EOF | oc create -f -
apiVersion: tekton.dev/v1beta1
kind: TaskRun
metadata:
  generateName: mas-devops-cluster-monitoring-
spec:
  taskRef:
    kind: Task
    name: mas-devops-cluster-monitoring
  params:
  - name: prometheus_storage_class
    value: "ibmc-block-gold"
  - name: prometheus_alertmgr_storage_class
    value: "ibmc-file-gold-gid"
  - name: prometheus_userworkload_storage_class
    value: "ibmc-block-gold"
  resources: {}
  serviceAccountName: pipeline
  timeout: 24h0m0s
EOF
```


License
-------

EPL-2.0
