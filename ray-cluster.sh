#!/bin/bash
bash -c 'cat << EOF > ray-cluster.yaml
apiVersion: ray.io/v1alpha1
kind: RayCluster
metadata:
  labels:
    controller-tools.k8s.io: "1.0"
    # A unique identifier for the head node and workers of this cluster.
  name: example-cluster
  namespace: kubeflow-user-example-com
spec:
  rayVersion: "2.6.1"
  ######################headGroupSpec#################################
  # head group template and specs, (perhaps "group" is not needed in the name)
  headGroupSpec:
    # Kubernetes Service Type, valid values are "ClusterIP", "NodePort" and "LoadBalancer"
    serviceType: ClusterIP
    # for the head group, replicas should always be 1.
    # headGroupSpec.replicas is deprecated in KubeRay >= 0.3.0.
    replicas: 1
    # the following params are used to complete the ray start: ray start --head --block --dashboard-host: "0.0.0.0" ...
    rayStartParams:
      num-gpus: "2"
      dashboard-host: "0.0.0.0"
      block: "true"
    #pod template
    template:
      metadata:
        labels:
          # custom labels. NOTE: do not define custom labels start with `raycluster.`, they may be used in controller.
          # Refer to https://kubernetes.io/docs/concepts/overview/working-with-objects/labels/
          rayCluster: raycluster-sample # will be injected if missing
          rayNodeType: head # will be injected if missing, must be head or wroker
          groupName: headgroup # will be injected if missing
        # annotations for pod
        annotations:
          sidecar.istio.io/inject: "false"
      spec:
        containers:
        - name: ray-head
          image:  rayproject/ray-ml:2.6.1.7474f8-gpu
          ports:
          - containerPort: 6379
            name: gcs
          - containerPort: 8265
            name: dashboard
          - containerPort: 10001
            name: client
          - containerPort: 8000
            name: serve
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh","-c","ray stop"]
          resources:
            limits:
              nvidia.com/gpu: "1"
              cpu: "1"
              memory: "8G"
            requests:
              nvidia.com/gpu: "1"
              cpu: "500m"
              memory: "4G"
  workerGroupSpecs:
  # the pod replicas in this group typed worker
  - replicas: 1
    minReplicas: 1
    maxReplicas: 10
    # logical group name, for this called large-group, also can be functional
    groupName: large-group
    # if worker pods need to be added, we can simply increment the replicas
    # if worker pods need to be removed, we decrement the replicas, and populate the podsToDelete list
    # the operator will remove pods from the list until the number of replicas is satisfied
    # when a pod is confirmed to be deleted, its name will be removed from the list below
    #scaleStrategy:
    #  workersToDelete:
    #  - raycluster-complete-worker-large-group-bdtwh
    #  - raycluster-complete-worker-large-group-hv457
    #  - raycluster-complete-worker-large-group-k8tj7
    # the following params are used to complete the ray start: ray start --block
    rayStartParams:
      block: "true"
    #pod template
    template:
      metadata:
        labels:
          rayCluster: raycluster-complete # will be injected if missing
          rayNodeType: worker # will be injected if missing
          groupName: large-group # will be injected if missing
        annotations:
          sidecar.istio.io/inject: "false"
      spec:
        containers:
        - name: machine-learning # must consist of lower case alphanumeric characters or "-", and must start and end with an alphanumeric character (e.g. "my-name",  or "123-abc"
          image: rayproject/ray-ml:2.6.1.7474f8-gpu
          # environment variables to set in the container.Optional.
          # Refer to https://kubernetes.io/docs/tasks/inject-data-application/define-environment-variable-container/
          lifecycle:
            preStop:
              exec:
                command: ["/bin/sh","-c","ray stop"]
          # use volumeMounts.Optional.
          # Refer to https://kubernetes.io/docs/concepts/storage/volumes/
          volumeMounts:
            - mountPath: /var/log
              name: log-volume
          resources:
            limits:
              nvidia.com/gpu: "1"
              cpu: "1"
              memory: "8G"
            requests:
              nvidia.com/gpu: "1"
              cpu: "500m"
              memory: "4G"
        initContainers:
        # the env var $RAY_IP is set by the operator if missing, with the value of the head service name
        - name: init-myservice
          image: busybox:1.28
          # Change the cluster postfix if you dont have a default setting
          command: ["sh", "-c", "until nslookup $RAY_IP.$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace).svc.cluster.local; do echo waiting for myservice; sleep 2; done"]
        # use volumes
        # Refer to https://kubernetes.io/docs/concepts/storage/volumes/
        volumes:
          - name: log-volume
            emptyDir: {}
EOF'

sudo k3s kubectl apply -f ray-cluster.yaml