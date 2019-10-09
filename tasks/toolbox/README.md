# toolbox is a small container with handy tools for accessing resource within cluster, mostly for testing

# Deployment
```
cat <<EOF | kubectl create -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  labels:
    run: henrytoolbox
  name: toolbox
spec:
  replicas: 1
  selector:
    matchLabels:
      run: henrytoolbox
  template:
    metadata:
      labels:
        run: henrytoolbox
    spec:
      hostname: toolbox
      containers:
      - image: henryhhl18/toolbox
        name: toolbox
        command: ["sleep"]
        args: ["30000d"]
EOF
```
