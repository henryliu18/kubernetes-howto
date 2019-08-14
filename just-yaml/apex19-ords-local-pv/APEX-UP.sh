#!/bin/bash
kubectl apply -f APEX-PROD.yaml
while [[ $(kubectl get pods -l run=apex19 -o 'jsonpath={..status.conditions[?(@.type=="Ready")].status}') != "True" ]]; do echo "waiting for pod" && sleep 1; done
kubectl apply -f ORDS-PROD.yaml
