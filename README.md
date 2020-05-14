# SanJose Data Platform Setup on Containers
## Contents
1. Kubernetes Deployment - master
1. Kubernetes Deployment - Client
1. Scaling Kubernetes and Adding Workers
1. Removing Workers
1. Reset Kubernetes master
1. stopping and restarting kubernetes
1. Application Deployment - Spark
1. Application Deployment - Zeppelin
1. Application Deployment - Ambari
1. Application Deployment - Hortonworks Data Platform
1. Application Deployment - Kafka

## Kubernetes Deployment - Server
The below commands are to be executed on kubernetes master.
1.  **Setup:** Change the user to root using command **sudo su** if you are not the root already.
1.  **Setup:** Install git package to checkout from Git using the command.
   **yum install git**
1.  **Setup:** Check out the https://github.com/Harish-sr/Kubernetes_deploy/ repo to deploy the kubernetes using the command
**git clone https://github.com/Harish-sr/Kubernetes_deploy.git**

    **Validation:** Check for a folder kubernetes_deploy to be created in your current location
1.  **Setup:** Update the kubernetes repo file into the yum repo by coping the contents of file **kuberepo.txt** that is available in the folder where the kubernetes deployment repo gets downloaded to **/etc/yum.repos.d/kubernetes.repo** using vi editor

    **Validation:** The command **yum repolist** should list the kubernetes repository added
1.  **Setup:** Change the permission of the file KubernetesServer.sh using **filechmod 775 KubernetesServer.sh**
    
    **Validation:** Perform ls -l command and verify if the permissions are changed
1.  **Setup:** Run the KubernetesServer.sh script on the master node using the command **./KubernetesServer.sh**. 
    
    **Validation:** 
    1. In the output of the script look for token like the one below
    **kubeadm join 10.23.126.1:6443 --token 7qgrxo.rsky4j9dxha8w9q6 \
    --discovery-token-ca-cert-hash sha256:9356ca0d1ce463d89a2f50c469e6f325c61b2a7eae9b8c7b48ba52a1fbd40f4c**
    1. Save the token from the previous step to be distributed to all the slave machines in later steps
    1. Run the command **kubectl get pods --all-namespaces** which will list all the system pods created. 
    1. Expect all system pods to be in running state except dnscore pods
1.  **Setup:** Apply the network plugin **weave** using the commands
    **export kubever=$(kubectl version | base64 | tr -d '\n')**
    **kubectl apply -f "https://cloud.weave.works/k8s/net?k8s-version=$kubever"**
    
    **Validation:** 
    1. Wait for the weave to start after which wait for coredns pods to change state to running by repeatedly checking on executing the command
    **kubectl get pods --all-namespaces**
    
    
## Kubernetes Deployment - Worker 
The below commands are to be executed on kubernetes worker.
1.  **Setup:** Change the user to root using command **sudo su** if you are not the root already.
1.  **Setup:** Install git package to checkout from Git using the command.
   **yum install git**
1.  **Setup:** Check out the https://github.com/Harish-sr/Kubernetes_deploy/ repo to deploy the kubernetes using the command
**git clone https://github.com/Harish-sr/Kubernetes_deploy.git**

    **Validation:** Check for a folder kubernetes_deploy to be created in your current location
1.  **Setup:** Update the kubernetes repo file into the yum repo by coping the contents of file **kuberepo.txt** that is available in the folder where the kubernetes deployment repo gets downloaded to **/etc/yum.repos.d/kubernetes.repo** using vi editor

    **Validation:** The command **yum repolist** should list the kubernetes repository added
1.  **Setup:** Change the permission of the file KubernetesWorker.sh using **filechmod 775 KubernetesWorker.sh**
    
    **Validation:** Perform ls -l command and verify if the permissions are changed
1.  **Setup:** Run the KubernetesWorker.sh script on the worker node using the command **./KubernetesWorker.sh**. 
    
    **Validation:** 
    1. Run the command **kubectl get pods --all-namespaces** which will list all the system pods created. 
    
1.  The worker node setup should be done within 24 hours of master node setup. Please use the token from the master node setup which was saved while setting up the master. If the worker node setup is done after 24 hours please follow the steps in the next section **Scaling Kubernetes and Adding Workers** which involves generating a token in different way **Setup:** Execute the saved token command from the master node setup similar to **kubeadm join 10.23.126.1:6443 --token 7qgrxo.rsky4j9dxha8w9q6 \
    --discovery-token-ca-cert-hash sha256:9356ca0d1ce463d89a2f50c469e6f325c61b2a7eae9b8c7b48ba52a1fbd40f4c**.
   **Validation:** Go back to master node to check for all the new worker nodes created using command **kubectl get nodes**
    
**NOTE:** All the worker nodes have to be setup within 24 hours after token generation on the master node. If not or if more nodes are to be added later any time after 24 hours, follow the steps detailed in section **Scaling Kubernetes and adding more workers**.

## Scaling Kubernetes and Adding Workers

**Steps on the master node:**
1. Execute command **kubeadm token create** which will generate output similar to 
   **5didvk.d09sbcov8ph2amjw**
1. To get the value of **--discovery-token-ca-cert-hash**, execute the following command chain on the master node,
   **openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | \
   openssl dgst -sha256 -hex | sed 's/^.* //'** 
   The output of this command will be similar to 
   **8cb2de97839780a412b93877f8507ad6c94f73add17d5d7058e91741c9d5ec78**
1. With both the above tokens form the join command like, 
   **kubeadm join 10.23.126.1:6443 --token 5didvk.d09sbcov8ph2amjw \
    --discovery-token-ca-cert-hash sha256:8cb2de97839780a412b93877f8507ad6c94f73add17d5d7058e91741c9d5ec78**.

**Steps on the worker nodes:**
1. Follow all the steps mentioned for the worker node above and use the tokens generated in the previous steps under **Steps on the master node** for the join command.

## Removing Workers
**Setup:**
1. Login to the node
1. Execute command **sudo su** to change to root user
1. Execute command **kubeadm reset** to reset master
1. Execute command **rm -rf /etc/cni/net.d **
1. Execute command **rm -rf $HOME/.kube/config**
1. Execute command **yum remove kubeadm kubectl kubelet docker**

**Validation:** 
1. Execute command **kubeadm** and the command should not be found
1. Execute command **docker** and the command should not be found

## Reset Kubernetes master
**Setup:**
1. Login to the node
1. Execute command **sudo su** to change to root user
1. Execute command **kubeadm reset** to reset master
1. Execute command **rm -rf /etc/cni/net.d **
1. Execute command **rm -rf $HOME/.kube/config**
1. Execute command **yum remove kubeadm kubectl kubelet docker**

**Validation:** 
1. Execute command **kubeadm** and the command should not be found
1. Execute command **docker** and the command should not be found

## stopping/restarting kubernetes worker and master
1. The kubernetes application launches itself automatically after a kubernetes worker\master is restarted. To enable the automatic restart we need to set swap to off in /etc/fstab using command 
**vi /etc/fstab** look for swap and add a comment to that line like this 
** # /dev/mapper/centos-swap swap                    swap    defaults        0 0**
1. Once a worker is shutdown the master will stop scheduling pods to the worker in 5 mins and also redistribute the pods that were running in the shutdown pod on other workers.

## Application Deployment - Spark

### Prerequisites

1. Kubernetes cluster has to be installed and running
1. Ensure kubectl command line tool is installed and configured to talk to Kubernetes cluster
1. Ensure Kubernetes cluster is running kube-dns or an equivalent integration

### Setup:
1. **Setup:** Download and install the latest spark cluster from https://github.com/kubernetes/examples/tree/master/staging/spark using command  **git clone https://github.com/kubernetes/examples.git**

   **Validation:** Ensure a folder by name **examples** is created in current location.
   
1. **Setup:** Create namespace using 
   **kubectl create -f examples/staging/spark/namespace-spark-cluster.yaml**
   
   **Validation:** Execute command **kubectl get namespaces** which should list the spark cluster
   
   NAME          LABELS             STATUS
   
   default       <none>             Active
   
   spark-cluster name=spark-cluster Active
   
1. **Setup:** Start the Master service: This Master service is the master service for a Spark cluster.
   Use the examples/staging/spark/spark-master-controller.yaml file to create a replication controller running the Spark Master service using command   
   **kubectl create -f examples/staging/spark/spark-master-controller.yaml -n spark-cluster**
   
   **Validation:** The below must be the output of the command
   **replicationcontroller "spark-master-controller" created**
   
1. **Setup:** Use the examples/staging/spark/spark-master-service.yaml file to create a logical service endpoint that Spark workers can use to access the Master pod as below,
   **kubectl create -f examples/staging/spark/spark-master-service.yaml -n spark-cluster**
   
   **Validation:** The below must be the output of the command
   **service "spark-master" created**
   
1. **Setup:** Check if Master is running and is accessible using command 
   **kubectl get pods -n spark-cluster**
   
   **Validation:** The below must be the output of the command
   
   NAME                            READY     STATUS    RESTARTS   AGE
   
   spark-master-controller-5u0q5   1/1       Running   0          8m
   
1. **Setup:** Check logs to see the status of the master. (Use the pod retrieved from the previous output.)
   **kubectl logs spark-master-controller-5u0q5 -n spark-cluster**

   **Validation:** The below must be the output of the command
   starting org.apache.spark.deploy.master.Master, logging to /opt/spark-1.5.1-bin-hadoop2.6/sbin/../logs/spark--          org.apache.spark.deploy.master.Master-1-spark-master-controller-g0oao.out
   
   Spark Command: /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java -cp /opt/spark-1.5.1-bin-hadoop2.6/sbin/../conf/:/opt/spark-1.5.1-bin-hadoop2.6/lib/spark-assembly-1.5.1-hadoop2.6.0.jar:/opt/spark-1.5.1-bin-hadoop2.6/lib/datanucleus-rdbms-3.2.9.jar:/opt/spark-1.5.1-bin-hadoop2.6/lib/datanucleus-core-3.2.10.jar:/opt/spark-1.5.1-bin-hadoop2.6/lib/datanucleus-api-jdo-3.2.6.jar -Xms1g -Xmx1g org.apache.spark.deploy.master.Master --ip spark-master --port 7077 --webui-port 8080

   ========================================

   15/10/27 21:25:05 INFO Master: Registered signal handlers for [TERM, HUP, INT]

   15/10/27 21:25:05 INFO SecurityManager: Changing view acls to: root

   15/10/27 21:25:05 INFO SecurityManager: Changing modify acls to: root

   15/10/27 21:25:05 INFO SecurityManager: SecurityManager: authentication disabled; ui acls disabled; users with view permissions: Set(root); users with modify permissions: Set(root)

   15/10/27 21:25:06 INFO Slf4jLogger: Slf4jLogger started

   15/10/27 21:25:06 INFO Remoting: Starting remoting

   15/10/27 21:25:06 INFO Remoting: Remoting started; listening on addresses :[akka.tcp://sparkMaster@spark-master:7077]

   15/10/27 21:25:06 INFO Utils: Successfully started service 'sparkMaster' on port 7077.

   15/10/27 21:25:07 INFO Master: Starting Spark master at spark://spark-master:7077

   15/10/27 21:25:07 INFO Master: Running Spark version 1.5.1

   15/10/27 21:25:07 INFO Utils: Successfully started service 'MasterUI' on port 8080.

   15/10/27 21:25:07 INFO MasterWebUI: Started MasterWebUI at http://spark-master:8080

   15/10/27 21:25:07 INFO Utils: Successfully started service on port 6066.

   15/10/27 21:25:07 INFO StandaloneRestServer: Started REST server for submitting applications on port 6066

   15/10/27 21:25:07 INFO Master: I have been elected leader! New state: ALIVE

1. **Setup:** Start your Spark workers
The Spark workers do the heavy lifting in a Spark cluster. They provide execution resources and data cache capabilities for your program.

The Spark workers need the Master service to be running.

Use the examples/staging/spark/spark-worker-controller.yaml file to create a replication controller that manages the worker pods.

**kubectl create -f examples/staging/spark/spark-worker-controller.yaml -n spark-cluster**

   **Validation:** The below must be the output of the command
   replicationcontroller "spark-worker-controller" created

1. **Setup:** Check to see if the workers are running
   **kubectl get pods -n spark-cluster**
   
   **Validation:** The below must be the output of the command
   
   NAME                            READY     STATUS    RESTARTS   AGE
   
   spark-master-controller-5u0q5   1/1       Running   0          25m
   
   spark-worker-controller-e8otp   1/1       Running   0          6m
   
   spark-worker-controller-fiivl   1/1       Running   0          6m
   
   spark-worker-controller-ytc7o   1/1       Running   0          6m
   
## Application Deployment - Zeppelin

Zeppelin needs the spark-master service to be running.
1. **Setup:** Run command **kubectl create -f examples/staging/spark/zeppelin-controller.yaml -n spark-cluster**
   **Validation:** The below must be the output of the command
   **replicationcontroller "zeppelin-controller" created**

1. **Setup:** Install the corresponding service using command **kubectl create -f examples/staging/spark/zeppelin-service.yaml -n spark-cluster**
   
   **Validation:** The below must be the output of the command
   **service "zeppelin" created**
   
1. **Setup:** Check to see if Zeppelin is running
   **kubectl get pods -l component=zeppelin -n spark-cluster**
   
   **Validation:** The below must be the output of the command
   
   NAME                        READY     STATUS    RESTARTS   AGE
   
   zeppelin-controller-ja09s   1/1       Running   0          53s

1. **Setup:** Validate the spark and Zeppelin setup using sample code 
   1. Run command **kubectl exec zeppelin-controller-ja09s -it pyspark -n spark-cluster** which will open up zeppelin as below
   1. Execute this Python snippet:
      
   from math import sqrt; from itertools import count, islice

   def isprime(n):
    return n > 1 and all(n%i for i in islice(count(2), int(sqrt(n)-1)))

    nums = sc.parallelize(xrange(10000000))
    print nums.filter(isprime).count()
      
   **Validtion:** The below will be the output of this step
   664579
   
   Congratulations, you now know how many prime numbers there are within the first 10 million numbers!

## Application Deployment - Kafka
**Setup:**
1. Login to the kumernetes master
1. Execute command **kubectl apply -f zoo-keeper.yaml** to start the zookeeper server before starting the kafka services
   **Validation:** The below must be the output of the command
   **deployment.extensions/zookeeper-deployment-1 created**
   **service/zoo1 created**   
   **Validation: kubectl get pods** The below must be the output of the command

   NAMESPACE     NAME                                             READY   STATUS    RESTARTS   AGE

   default       zookeeper-deployment-1-67786c9fc4-tp9kk          1/1     Running   0          34s


1. Execute command **kubectl apply -f kafka-service.yaml** to start the service for kafka
   **Validation:** The below must be the output of the command
   **service/kafka-service created**
1. Execute command **kubectl describe svc kafka-service** to get the output like below having the IP address of the kafka service
   copy the line **IP: 10.102.113.183** for further use
      
   Name:                     kafka-service

   Namespace:                default

   Labels:                   name=kafka

   Annotations:              kubectl.kubernetes.io/last-applied-configuration:
                            {"apiVersion":"v1","kind":"Service","metadata":{"annotations":{},"labels":{"name":"kafka"},"name":"kafka-service","namespace":"default"},"...
                            
   Selector:                 app=kafka,id=0

   Type:                     NodePort

   IP:                       10.102.113.183

   Port:                     kafka-port  9092/TCP

   TargetPort:               9092/TCP

   NodePort:                 kafka-port  30030/TCP

   Endpoints:                <none>

   Session Affinity:         None

   External Traffic Policy:  Cluster

   Events:                   <none>


1. Execute command **kubectl apply -f kafka-broker.yaml** to deply the broker
   **Validation:** The below must be the output of the command
   **deployment.extensions/kafka-broker0 created**
   Execute command **kubectl get pods** to see the kafka broker started
   
   NAMESPACE     NAME                                             READY   STATUS    RESTARTS   AGE

   default       zookeeper-deployment-1-67786c9fc4-tp9kk          1/1     Running   0          34s

   default       kafka-broker0-8569c45479-zsfjq                   1/1     Running   0          15m

## Add the package dependencies to be upgraded with OS or other major component is updated
