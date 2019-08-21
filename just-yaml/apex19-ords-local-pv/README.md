#README.md

Deploy Oracle Apex 19.1 and ORDS webapp on Tomcat in 2 containers, database files are going to be stored on a local directory that is defined as a persistent volume in Kubernetes

Apply sequences

- create local directory for pv
  - APEX-PERSISTENT-VOLUME.yaml
- COPYDB-JOB.yaml
- APEX-PROD.yaml
- ORDS-PROD.yaml
