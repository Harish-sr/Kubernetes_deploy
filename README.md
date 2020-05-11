# SanJose Data Platform Setup on Containers
## Contents
1. Kubernetes Deployment - Server
2. Kubernetes Deployment - Client
3. Application Deployment - Spark
4. Application Deployment - Ambari
5. Application Deployment - Hortonworks Data Platform

## Kubernetes Deployment - Server
1.  **Setup:** Change the user to root using command **sudo su** if you are not the root already.
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
    
    command to add a slave later ############################
    command to resetup things #######################
    add the package dependencies to be upgraded with OS or other major component is updated

 

####################Worker deployment #################
1. update the kubernetes repo file into the yum repo using the file kuberepo.txt. which was downloaded from git
    vi /etc/yum.repos.d/kubernetes.repo 
    and past the contents of kuberepo.txt file
    change the permission of the filechmod 775 KubernetesWorker.sh
4.  run the Kubernetesworker.sh script on the worker nodes 
5. RUN the captured token command from the master after the Kubernetesworker.sh is finished running.
    check for all the new node added using "kubectl get nodes" on the master node
    
    
    ##############################Application deployment#############################
1. install the latest spark cluster using https://github.com/kubernetes/examples/tree/master/staging/spark
2. download from git location"github clone https://github.com/kubernetes/examples.git"
3. Please follow the document for spark deployment
    
    Step Zero: Prerequisites
This example assumes

You have a Kubernetes cluster installed and running.
That you have the kubectl command line tool installed in your path and configured to talk to your Kubernetes cluster
That your Kubernetes cluster is running kube-dns or an equivalent integration.
Optionally, your Kubernetes cluster should be configured with a Loadbalancer integration (automatically configured via kube-up or GKE)

Step One: Create namespace
$ kubectl create -f examples/staging/spark/namespace-spark-cluster.yaml
Now list all namespaces:

$ kubectl get namespaces
NAME          LABELS             STATUS
default       <none>             Active
spark-cluster name=spark-cluster Active
To configure kubectl to work with our namespace, we will create a new context using our current context as a base:

$ CURRENT_CONTEXT=$(kubectl config view -o jsonpath='{.current-context}')
$ USER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.user}')
$ CLUSTER_NAME=$(kubectl config view -o jsonpath='{.contexts[?(@.name == "'"${CURRENT_CONTEXT}"'")].context.cluster}')
$ kubectl config set-context spark --namespace=spark-cluster --cluster=${CLUSTER_NAME} --user=${USER_NAME}
$ kubectl config use-context spark
Step Two: Start your Master service
The Master service is the master service for a Spark cluster.

Use the examples/staging/spark/spark-master-controller.yaml file to create a replication controller running the Spark Master service.

$ kubectl create -f examples/staging/spark/spark-master-controller.yaml
replicationcontroller "spark-master-controller" created
Then, use the examples/staging/spark/spark-master-service.yaml file to create a logical service endpoint that Spark workers can use to access the Master pod:

$ kubectl create -f examples/staging/spark/spark-master-service.yaml
service "spark-master" created
Check to see if Master is running and accessible
$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
spark-master-controller-5u0q5   1/1       Running   0          8m
Check logs to see the status of the master. (Use the pod retrieved from the previous output.)

$ kubectl logs spark-master-controller-5u0q5
starting org.apache.spark.deploy.master.Master, logging to /opt/spark-1.5.1-bin-hadoop2.6/sbin/../logs/spark--org.apache.spark.deploy.master.Master-1-spark-master-controller-g0oao.out
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
Once the master is started, we'll want to check the Spark WebUI. In order to access the Spark WebUI, we will deploy a specialized proxy. This proxy is necessary to access worker logs from the Spark UI.

Deploy the proxy controller with examples/staging/spark/spark-ui-proxy-controller.yaml:

$ kubectl create -f examples/staging/spark/spark-ui-proxy-controller.yaml
replicationcontroller "spark-ui-proxy-controller" created
We'll also need a corresponding Loadbalanced service for our Spark Proxy examples/staging/spark/spark-ui-proxy-service.yaml:

$ kubectl create -f examples/staging/spark/spark-ui-proxy-service.yaml
service "spark-ui-proxy" created
After creating the service, you should eventually get a loadbalanced endpoint:

$ kubectl get svc spark-ui-proxy -o wide
 NAME             CLUSTER-IP    EXTERNAL-IP                                                              PORT(S)   AGE       SELECTOR
spark-ui-proxy   10.0.51.107   aad59283284d611e6839606c214502b5-833417581.us-east-1.elb.amazonaws.com   80/TCP    9m        component=spark-ui-proxy
The Spark UI in the above example output will be available at http://aad59283284d611e6839606c214502b5-833417581.us-east-1.elb.amazonaws.com

If your Kubernetes cluster is not equipped with a Loadbalancer integration, you will need to use the kubectl proxy to connect to the Spark WebUI:

kubectl proxy --port=8001
At which point the UI will be available at http://localhost:8001/api/v1/proxy/namespaces/spark-cluster/services/spark-master:8080/.

Step Three: Start your Spark workers
The Spark workers do the heavy lifting in a Spark cluster. They provide execution resources and data cache capabilities for your program.

The Spark workers need the Master service to be running.

Use the examples/staging/spark/spark-worker-controller.yaml file to create a replication controller that manages the worker pods.

$ kubectl create -f examples/staging/spark/spark-worker-controller.yaml
replicationcontroller "spark-worker-controller" created
Check to see if the workers are running
If you launched the Spark WebUI, your workers should just appear in the UI when they're ready. (It may take a little bit to pull the images and launch the pods.) You can also interrogate the status in the following way:

$ kubectl get pods
NAME                            READY     STATUS    RESTARTS   AGE
spark-master-controller-5u0q5   1/1       Running   0          25m
spark-worker-controller-e8otp   1/1       Running   0          6m
spark-worker-controller-fiivl   1/1       Running   0          6m
spark-worker-controller-ytc7o   1/1       Running   0          6m

$ kubectl logs spark-master-controller-5u0q5
[...]
15/10/26 18:20:14 INFO Master: Registering worker 10.244.1.13:53567 with 2 cores, 6.3 GB RAM
15/10/26 18:20:14 INFO Master: Registering worker 10.244.2.7:46195 with 2 cores, 6.3 GB RAM
15/10/26 18:20:14 INFO Master: Registering worker 10.244.3.8:39926 with 2 cores, 6.3 GB RAM
Step Four: Start the Zeppelin UI to launch jobs on your Spark cluster
The Zeppelin UI pod can be used to launch jobs into the Spark cluster either via a web notebook frontend or the traditional Spark command line. See Zeppelin and Spark architecture for more details.

Deploy Zeppelin:

$ kubectl create -f examples/staging/spark/zeppelin-controller.yaml
replicationcontroller "zeppelin-controller" created
And the corresponding service:

$ kubectl create -f examples/staging/spark/zeppelin-service.yaml
service "zeppelin" created
Zeppelin needs the spark-master service to be running.

Check to see if Zeppelin is running
$ kubectl get pods -l component=zeppelin
NAME                        READY     STATUS    RESTARTS   AGE
zeppelin-controller-ja09s   1/1       Running   0          53s
Step Five: Do something with the cluster
Now you have two choices, depending on your predilections. You can do something graphical with the Spark cluster, or you can stay in the CLI.

For both choices, we will be working with this Python snippet:

from math import sqrt; from itertools import count, islice

def isprime(n):
    return n > 1 and all(n%i for i in islice(count(2), int(sqrt(n)-1)))

nums = sc.parallelize(xrange(10000000))
print nums.filter(isprime).count()
Do something fast with pyspark!
Simply copy and paste the python snippet into pyspark from within the zeppelin pod:

$ kubectl exec zeppelin-controller-ja09s -it pyspark
Python 2.7.9 (default, Mar  1 2015, 12:57:24)
[GCC 4.9.2] on linux2
Type "help", "copyright", "credits" or "license" for more information.
Welcome to
      ____              __
     / __/__  ___ _____/ /__
    _\ \/ _ \/ _ `/ __/  '_/
   /__ / .__/\_,_/_/ /_/\_\   version 1.5.1
      /_/

Using Python version 2.7.9 (default, Mar  1 2015 12:57:24)
SparkContext available as sc, HiveContext available as sqlContext.
>>> from math import sqrt; from itertools import count, islice
>>>
>>> def isprime(n):
...     return n > 1 and all(n%i for i in islice(count(2), int(sqrt(n)-1)))
...
>>> nums = sc.parallelize(xrange(10000000))

>>> print nums.filter(isprime).count()
664579
Congratulations, you now know how many prime numbers there are within the first 10 million numbers!

Do something graphical and shiny!
Creating the Zeppelin service should have yielded you a Loadbalancer endpoint:

$ kubectl get svc zeppelin -o wide
 NAME       CLUSTER-IP   EXTERNAL-IP                                                              PORT(S)   AGE       SELECTOR
zeppelin   10.0.154.1   a596f143884da11e6839506c114532b5-121893930.us-east-1.elb.amazonaws.com   80/TCP    3m        component=zeppelin
If your Kubernetes cluster does not have a Loadbalancer integration, then we will have to use port forwarding.

Take the Zeppelin pod from before and port-forward the WebUI port:

$ kubectl port-forward zeppelin-controller-ja09s 8080:8080
This forwards localhost 8080 to container port 8080. You can then find Zeppelin at http://localhost:8080/.

Once you've loaded up the Zeppelin UI, create a "New Notebook". In there we will paste our python snippet, but we need to add a %pyspark hint for Zeppelin to understand it:

%pyspark
from math import sqrt; from itertools import count, islice

def isprime(n):
    return n > 1 and all(n%i for i in islice(count(2), int(sqrt(n)-1)))

nums = sc.parallelize(xrange(10000000))
print nums.filter(isprime).count()
After pasting in our code, press shift+enter or click the play icon to the right of our snippet. The Spark job will run and once again we'll have our result!
