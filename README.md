# **Kubernetes Overview**

- [**Kubernetes Overview**](#kubernetes-overview)
  - [***Why Kubernetes***](#why-kubernetes)
    - [***Pod***](#pod)
    - [***Kubernetes Cluster***](#kubernetes-cluster)
    - [***Components in Control Plane Node***](#components-in-control-plane-node)
    - [***Components in Worker Node***](#components-in-worker-node)
    - [***Workflow***](#workflow)
    - [***Learning Setup***](#learning-setup)
    - [***Creating Pods: Imperative \& Declarative Way***](#creating-pods-imperative--declarative-way)
    - [***ReplicaSets and Replication Controller***](#replicasets-and-replication-controller)
    - [***Manifests and its Components***](#manifests-and-its-components)
    - [***Scaling Pods Manually***](#scaling-pods-manually)
    - [***Deployment***](#deployment)

## ***Why Kubernetes***

- Consider a service running on Docker containers across multiple machines in your data center. If any of these containers or their host machines fail, your service becomes inaccessible, leading to a production outage.
- Managing massive applications with multiple containers poses challenges, such as networking, exposing APIs, and allowing user access. While containers and virtual machines can address these issues, achieving fault tolerance and high availability requires orchestration.
- **Orchestration**: This concept enables seamless collaboration between multiple containers or microservices. Docker Swarm and Kubernetes are popular orchestration tools that solve this problem.
- For large-scale applications where scalability and high availability are crucial, orchestration is often the solution, making Kubernetes a necessary tool.

### ***Pod***

- A Pod is the smallest unit in Kubernetes, similar to how a container is the smallest unit in Docker.
- In Kubernetes, containers are created inside a Pod (one or many).
- A Pod can contain shared volumes, multiple containers, and a shared IP address.
- Typically, one container per Pod is used in the industry unless there is a specific use case for multiple containers.
- Each Pod must reside on a single server.
- Pods can be moved from one node to other node in the cluster.
- Each container in a pod share namespaces in that pod like the IP addresses or the shared volumes

### ***Kubernetes Cluster***

- A Kubernetes cluster is a group of machines (physical or virtual) that run containerized applications.
- Each machine/server in the cluster is called a node, and there can be multiple nodes in a cluster.
- Each node has one or more Pods, and each Pod usually contains one container. Pod is the smallest deployable unit in Kubernetes.
- A Kubernetes cluster has a Master node and worker nodes. The Master node manages the worker nodes.
- **Master Node**: The Master node's job is to manage load across worker nodes. All Pods and containers that run your application are deployed on the worker nodes.
- The Master node is the control plane and does not run client applications. It runs essential components to keep the cluster operational and to manage it.

### ***Components in Control Plane Node***

- **API Server**: The central component of the Kubernetes control plane that exposes the Kubernetes API. Using the API server, you can manage entire cluster and this can be done using kubectl or kube control.
- **Scheduler**: A service on the Master node that manages load distribution between the nodes in the cluster. The scheduler receives the request from the API server  and it decides which node to deploy the pod on.
- **Kube Controller Manager**: Manages everything in the cluster in terms of what should happen on each node.
- **Cloud Controller Manager**: Works with the cloud service provider to scale applications and perform other automated tasks.
- **etcd**: A distributed key-value store that stores the state of the cluster. It is used to store the logs and errors in the cluster. It stores data in a key-value pair format. Stores data in JSON. Any change made to the cluster is stored in etcd. It is a distributed database. It is used to store the state of the cluster. Only the API server can write to etcd. All other components can only read from etcd.
- **Kube CTL**: This is a command line tool that you can use to manage the cluster using command line. The way kubectl works is that the REST API communicates with the API server on the master node. The communication happens over HTTPS.

### ***Components in Worker Node***

- **Kubelet**: An essential component in a Kubernetes cluster that communicates with the API server on the Master node to receive commands to launch or destroy containers. It is the agent that runs on each node in the cluster. It is responsible for communication between the worker node and the master node.
- **Kube-Proxy**: Present on each node and used for network communications between all nodes.

### ***Workflow***

- The way the workflow in Kubernetes works is that when an administrator wants to deploy a pod on the cluster, they send a request to the API server on the Master node. The request to the API server is sent using the KubeCTL command line tool. The API server authenticates and validates the request made by the administrator.
- The API server then sends the request to the scheduler. The scheduler then decides which node to deploy the pod on and communicates this information back to the API Server.
- The API server then sends the information to the Kubelet on the node that the scheduler decided to deploy the pod on. Kubelet then launches the container on the node and communicates the information back to the API server.
- The API Server then sends this information to the etcd on the Master node and etcd stores this information. The API Server also communicates the same to the administrator stating that the pod has been successfully deployed.

### ***Learning Setup***

- **Install MiniKube**: MiniKube is a local kubernetes cluster which lets you setup a cluster locally and have your manager node and worker node on a single machine
- **Install Kind**: Just like minikube, kind is a tool for running local kubernetes clusters using Docker container. It is a more powerful tool than minikube and can be used to run more complex clusters. To install it on MacOS you can use Homebrew and run the following command:

  ```brew install kind```

- **Install kubectl**: kubectl is the command line tool that you can use to manage the cluster.
- **Create a Clutser**: Once you have installed kind and KubeCTL, run the following command to create a cluster
  
  ```kind create cluster --name test```

- The above command will create a cluster with the name test. This will be a single node cluster running the control plane and other essential components and also lets you run pods. You can then use the following command to get the cluster information.
  
  ```kubectl  cluster-info```

- **Multi-Node Cluster**: You can also deploy a multi node cluster using kind. To do this, you need to create a configuration file that defines the nodes in the cluster and then create the cluster.
- **Config File**: Save the below configuration in a file called anyname.yaml.

``` yaml
# three node (two workers) cluster config
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
- role: worker
- role: worker
```

- **Create Multi-Node Cluster**: Once you have the configuration file, you can create the cluster using the following command

  ``` kind create cluster --name anyname --config anyname.yaml ```

- **Verify Cluster**: Once the cluster is created, you can verify it using the following command

  ``` kubectl cluster-info --cluster=anyname ```

- Since you now have two clusters - a single node and a multi-node cluster, you need to specify a context for kubectl to use and hence you specify it using ***--cluster=clustername*** to get info about the cluster.
- **Contexts**: To see the contexts currently available, you can use the following command. The star symbol indicates the currently set context.
  
  ``` kubectl config get-contexts ```

- **Set Context**: To set a context to a specifc context, you can use the following command
  
  ``` kubectl config use-context anyname ```

- Now that you have a cluster set up, it is time to create some pods and look at multiple ways to create them

### ***Creating Pods: Imperative & Declarative Way***

- **Imperative Way**: The imperative way of creating pods is by using the ***kubectl run*** command. This command is used to run a pod using a simple command and it is the most basic way of creating pods. For example, to create a pod that runs a container with the name nginx, you can use the following:

  ``` kubectl run nginx --image=nginx:latest --port=80 ```

- The above command creates an nginx pod with the latest version of the nginx image and exposes port 80.
- **Declarative Way**: This is done using a yaml or JSON configuration file. YAML is the widely used configuration language for Kubernetes.  The yaml file defines the pod and its configuration. For example, to create a pod that runs nginx we can specify multiple metadata information in the yaml file. Navigate to [nginx.yaml](Config_Files/nginx.yaml).
- You can also write an imperative command and output that into a yaml file. For example, you can use the following command to create a pod and output the yaml

``` kubectl create pod nginx --image=nginx:latest --port=80 -o yaml > nginx.yaml ```

- **Apply Configuration**: Once you have the yaml file, you can apply the configuration to create the pod.
  
``` kubectl create -f nginx.yaml ```

- **Verify Pod**: Once the pod is created, you can verify it using the following command

``` kubectl get pods ```

``` kubectl describe pod nginx ```

- You can use the following command to exec (enter) the container to make any changes, navigate directories etc.

``` kubectl exec -it nginx -- /bin/bash ```

### ***ReplicaSets and Replication Controller***

- **Replication Controller**: Replication controllers are used to ensure that a specified number of replicas of a pod are running at any given time. They are used to ensure that a pod is always running. For example, a pod that we created crashes or is not available to the users or it  is not responding because of a lot of requests that are coming in which increases the load, the *replication controller* spins up a new pod to make sure the service or the pod is available at all times. This is one of the benefit of orchestration.
- Replication controller is deprecated and the new way of doing this is by using ***ReplicaSet***. ReplicaSet is a resource in Kubernetes that lets you do the same thing as a replica controller but with additional features. For example, ReplicaSet can be used to deploy multiple replicas of a pod across multiple nodes.
- ReplicaSet can also manage existing pods which is not a feature in replica controller.
- When a user is trying to access a service or app on the replicaset, the traffic hits the Replicaset first and then the replicaset manages the traffic by sending it to the appropriate pod.
- You can define replicaset when you create a pod config. For example, you can define a replicaset with 3 replicas of a pod in the yaml file. Navigate to [Replicaset.yaml](Config_Files/replicaset.yaml).

### ***Manifests and its Components***

- **Manifest:** Every Kubernetes configuration yaml file that we are writing is called a manifest. The manifest is used to define the configuration of the pod or the service or the replication controller or the deployment etc.
- Manifest has four key components to it and they are as follows:
  - **apiVersion**: This is the version of the Kubernetes API that we are using. For example, if we are using the v1 version of the Kubernetes API, we would specify it as v1. If the version of a specific kind is in a group, you would specify it as *group.v1*. For instance, the *ReplicaSet* kind is in a group called apps so you would specify it as *apps/v1.*
  - **kind**: This is the type of Kubernetes resource that we are defining. For example, if we are defining a pod, we write it as a *pod* or if it is a resource set, we mention the kind which is *resourceset*
- **metadata and Labels**: This is the metadata of the resource. For example, the name of the pod, the that we want to attach to the pod, we would specify it in the metadata section. Labels can be anything that you want to attach to the pod to identify it.
- **Spec:** Short for specification, this is where you specify the name of the container, container ports which needs to be exposed, image that needs to be used etc.
- The four components above are in every manifest. Some additional components are listed below
  - **replicas:**  This is used in a manifest to define the number of replicas that we want to create. For example, if we want to create 3 replicas, we mention 3
  - **selector:** This is used to select the pods that we want to manage. Every label that
  - **matchLabels:** This is specifically used for a kind - replicaset. This is used to select the pods that we want to manage. Every label that we specify here is managed by the replicaset to maintain high availability and error handling.
  - Here is an example manifest which includes all the above components:
  
```yaml
apiVersion: apps/v1
kind:  ReplicaSet
metadata:
  name: nginx-replicas
  labels:
    app: nginx
    env: test-pod
spec:
  template:
    metadata:
      labels:
        app: nginx
        env: test-pod
    spec:
      containers:
      - name: nginx-replicas
        image: nginx:latest
        ports:
          - containerPort: 80
  replicas: 3
  selector:
    matchLabels:
      env: test-pod
 ```

### ***Scaling Pods Manually***

- **Manually Scaling Pods:** To scale the number of replicas, there is multiple ways as follows:
- **Updating the Manifest:** One way to scale the number of replicas is to update the manifest. For example, if we want to scale the pods from 3 to 5, we update the manifest and apply it again which scales the pods to 5.
- **Changing the Live Object:** You can run the following command to enter the live object and edit it to scale up the number of pods. Once you make changes, you just need to save your changes and the pod is scaled. For instance:

```kubectl
kubectl edit rs/nginx-replicas
```

- **Using the Scale Command:** You can use the scale command to scale the number of pods.

```kubectl
kubectl scale rs/nginx-replicas --replicas=5
```

### ***Deployment***

- **Deployment:** When we create a deployment, it manages the replicaset which in turn manages the pod. This updates the pods in a rolling method when we update the deployment. This is a more advanced way of managing the pods and is used when we want to update the pods in a rolling method.
- When we manage the changes using replicaset, there is possibility for downtime. But when we use deployment, the changes are rolled out in a rolling method which means there is no downtime and the service is still up and running.
- When we create a deployment, it creates the replicaset which in turn creates the pods.
- Navigate to[deployment.yaml](Config_Files/deployment.yaml) to take a look at the deployment manifest.
- The only change in the way manifest is written for deployment is to *change the kind from replicaset to deployment.*
