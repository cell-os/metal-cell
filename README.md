Title:       Metal Cell  
Subtitle:    Adobe's Mechanically Sympathetic Datacenter as a Computer
Project:     Metal Cell  
Author:      Cosmin Lehene  
Affiliation: Adobe  
Web:         httt://metal.corp.adobe.com  
Date:        June 2, 2014  
Misc:        The current version of this document lives in my stackedit.io - keep that in mind if you want to make any changes  

##Work in progress! 

Metal Cell
========
Metal Cell is Adobe's collaborative "Datacenter as a Computer" effort that attempts to move storage and compute from traditional, monolithic, multi single-node setups to homogenous pools of resources (cells) using existing Open Source technology.

"Exec Bullets"
--------------------  
* **Cost savings** through consolidated infrastructure and resource sharing that could reduce the hardware footprint by 10x.
* **Improved time to market** through accelerated development and self service provisioning of both infrastructure (IaaS) and cluster level services (PaaS)

"Dev Bullets"
------------------  
* Any language at any layer between hardware and end-application
* 

Abstract
-----------
The goal of Metal Cell is to improve Adobe products ***time to market*** and increase ***cost efficiency*** through shared, self-service infrastructure and cluster-level services.

The ***cell***  is the "new box". Applications or services that target a *cell* will, instead, access a much larger pool of resources (potentially spanning 10000s of nodes). 

The Cell "OS" is made of highly available distributed services that provide:
* Storage (block, structured, queue)
* Raw Compute (raw resources such as cores, RAM, IO)
* Computing Frameworks (batch, event, streaming)
* Resource allocation and isolation
* Scheduling

Concretely, the Metal Cell software integrates and builds on top of well known, open-source software such as Hadoop, Spark, Mesos, Docker, HBase, Zookeeper, etc. and exposes them as readily available integrated services that development teams could use as self-service, shared resources in all data centers.

**Mechanical Sympathy**
Rather than oversimplifying and hiding the complexities of distributed systems, Metal Cell is distilling them. While solving the common problems of distributed systems (storage, compute, scheduling, etc.) it abstracts, but not hide, their actual complexities and keeps them transparent to developers, so that applications can be written in a responsible manner in relation to them. 
The assumption here is that we can only abstract, but not make go away, things like speed of light, latency, bandwidth, etc. For this reason we should not hide them underneath [APIs that are supposed to make them look like running on a single machine](http://writings.quilt.org/2014/05/12/distributed-systems-and-the-end-of-the-api/).

Motivation
=========

**Time to Market**
Reduce new applications turnaround time from months to days enabling continuous delivery.

Traditional development forces the development teams to be able to code, deploy and operate full stacks. With the proliferation of distributed systems these stacks may involve more than 10 different services, making development even more complex. Many times more time ends up being spent in setting up and maintaining development environments[^footnote] and integration with all components, dealing with versions conflicts, etc. than on the sell-able product software. 
	
*Note: More, when releasing these systems to production, there's an assumption that these could be handed over to operations teams. 

By developing applications and services against cells (cluster-level services) we are able to decouple a lot of the distributed systems complexity from the application logic. Self-service provisioning enables developers to run applications against existing clusters. This reduces the development time substantially. 

Provisioning and deployment become a matter of consuming a service so time to market is further reduced.

By relieving development teams from this overhead, more services can be developed and tested instead.

R&D 
Many times we face a chicken and egg problem when it comes to new services. We need infrastructure to test and we wait to be ready with software in order to order it. 
Being able to "tap" into existing infrastructure across data centers and public cloud would speed up prototyping.

Lean hardware provisioning 


**Cost Efficiency**
Benefits from economy of scale should allow us to reduce our hardware footprint by 10x and decrease operational overhead substantially.

The infrastructure load in typical datacenters (as in Adobe's) is between 1% and 10% (normally skewed towards 1%).
Unfortunately a physical node consumes ~50% of the total energy when idle. By collocating workloads we can increase hardware utilization rate substantially (highly efficient deployments get above 60% utilization).

Traditionally services are deployed in a monolithic fashion with a standard deployment containing dedicated machines for web servers, database servers and other roles. 
This is both energy inefficient and generally results in highly fragmented environments - with each service having it's own dedicated hardware profiles, software versions and operations teams. Also the operation teams need to be skilled enough to support the entire variety of the stack being used.

By consolidating on shared infrastructure less hardware profiles (generally 2 or 3 vs 10s) need to be used. This means less complexity to manage and debug but also improved discount rates from vendors, a larger pool of spare parts, etc. Nevertheless, it also removes the burden of hardware profile selection from product teams, that can now  model their expected load against a shared pool of granular resources (e.g. compute, memory, IO).

A similar effect is gained from consolidating the software stacks, starting from OS to the cluster-level software so operations teams now can focus on less, larger deployments, allowing creation of a "layer-based" expertise, essentially enabling sharing of the operations teams across different products. 

In order to accommodate traffic spikes, infrastructure is generally provisioned with a sizable "buffer". For some workloads spikes can be 10x of the normal traffic, so a large quantity of servers are dedicated to be idle for most of the time.
By sharing a larger infrastructure the additional capacity is much larger and can be both shared between multiple workloads and used in off-peak times.

By sharing infrastructure between workloads we could achieve a much higher compute efficiency. Also compute efficiency can now be measured uniformly accross an entire fleet along with all running workloads opening new optimization possibilities like [leveraging non-used cycles and cheap energy](http://googleblog.blogspot.ca/2014/05/better-data-centers-through-machine.html)


Metal Cell Architecture
==================

World view
----------------
* Global (the collection of all cells across the globe)
* Region
* Cell
* Pods
* Racks
* Nodes
* Containers

Introduction: Resource Isolation
--------------------------------------------

Economy of scale, resource utilization, resource sharing, etc.   
Overcommitting resources to increase resource utilization.

Imagine you'd have a store where each customer has it's own sales person.
That's generally nice, but it's also very expensive for both the store and the customer. Although there are stores like that (imagine an expensive watch store), generally the sales people are *overcommitted* - hence they serve more than one customer. *Overcommitting* is something that has been used in computing for quite a while.  Multitasking is one way to share the CPU between multiple tasks, hence overcommitting it. Overcommitting doesn't necessarily cause performance degradation, but that's probable depending on the overcommit factor.

The checkout line at your local store is an example of performance degradation when your normal wait time will get degraded. 

Economy of scale will determine the efficiency. The larger the store is the less probable is that there will be unutilized cashiers or customers that will stay in line for too long.

As you see resource utilization optimization is a common problem. However just as the local store may have an express line, we generally need to guarantee some service level agreement related to some resource. 


Introduction: Onion Layers
--------------------------------------
You can imagine Metal Cell as layers in an onion. 

Going from a small scale like a OS process to the OS environment and then to the cluster, we may need to worry about similar concerns, such as resource isolation or compatibility, however they'll have different scopes (and potentially solutions) with each level of abstraction (layer)

While at the OS level binary compatibility may be a concernt, generally at a cluster level it could be the service (RPC) compatibility that we'd be concerned with.

At an *OS level* the Kernel manages the local CPU cores, memory and IO resources.
At a *cluster level* there's a wider view of the resources which includes both servers and the networking equipment which they share.

* 3 large layer categories: infrastructure, custer, app.

Resource Management and Isolation
----------------------------------------------------

### Infrastructure-Level Resource Management: Plumbing*

Although the resources may vary with each service, there are a few low level basic resources that matter.

At the infrastructure (device)-level, the main resources we're concerned with are CPU, memory, IO, disk. Both memory and IO have latency and bandwidth measures that we care**

[footnote: as the server itself has it's own layers, internal subsystems such as network or disk controllers will have their own resource allocation and isolation semantics, however keep in mind that a layer is supposed to abstract wherever possible - think of virtual memoy for example. One could say that given the actual resources such as sillicon chips and energy things could be simplified, while we agree, we need to remain pragmatic]

**footnote:  as a generalization you can imagine just two/three type of resources: those that store and those that process and those that make it possible to transport data from storage to processing.  The measures that we'll mostly care about are capacity, bandwidth and latency. 

#### Resource Isolation and Containers
To ensure QoS when sharing resources an isolation mechanism is required.
For example, the express line in your local store has an item-limit (generally less than 10-15). That's a good example of resource isolation to protect blocking the resource (cashier0 from a customer with 5 carts for example. 

In a similar fashion an OS provides mechanisms aimed to isolate resources.  
The Linux Kernel has namespaces and cgroups[^cgroops-foot] as building blocks to offer resource isolation.

* Namespaces and cgroups  
	* [namespaces](http://lwn.net/Articles/531114/)
	* [cgroups](https://www.kernel.org/doc/Documentation/cgroups/cgroups.txt)
	* http://www.haifux.org/lectures/299/netLec7.pdf
* Containers
  * [Linux LXC](https://linuxcontainers.org/), [Google LMCTFY](https://github.com/google/lmctfy), [libcontainer](https://github.com/docker/libcontainer)
  * [Docker](https://www.docker.io)

#### Docker Containers
Docker is a container engine with the goal of aiding application packaging and running in lightweight containers. 

##Resources
[cgroups redesign](http://www.linux.com/news/featured-blogs/200-libby-clark/733595-all-about-the-linux-kernel-cgroups-redesign)  
[Linux Plumbers Conference](http://www.linuxplumbersconf.org)  
[LMCTFY presentation](http://www.linuxplumbersconf.org/2013/ocw//system/presentations/1239/original/lmctfy%20(1).pdf)  
[Containers RFC draft](https://github.com/containers/container-rfc)  
[Google Embraces Docker](http://www.wired.com/2014/06/eric-brewer-google-docker/)  
[Google CAdvisor](https://github.com/google/cadvisor)  
[Google Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes)  

### Cell-Level Resource Management
With proper node level resource isolation in hand we can look at the cluster-level view of resources.
Just like we can keep track of the available resource on a single OS a similar approach is needed at a cluster level. Resource management involves tracking of free and used resources and potentially the scheduling for the workloads. 

As a container spans a single node, the maximum capacity for a container will be limited to the maximum free capacity on a node. Hence resource managers need to keep track of what resources are available where and be able to allocate / de-allocte resources.

Cluster level resource managers such as Mesos and the YARN Resource Manager handle the management of some* of the resources along with their physical locations.

As a cell will have multiple nodes communicating over the network through switches we can see how resource management is not limited to nodes and containers, but also the networking equipment. 

Containers deal with node level resource isolation of resources such as CPU, Memory, Disk IO, Network IO memory, disk and network resources are measured in both bandwidth and latency. However as workloads likely span across many containers network will be a shared resource limited by physical hardware external to the node. While one could argue that switches could be containerized as well, that abstraction is limited and unlikely to scale properly. Instead the inter-node connection (bandwidth and latency) would probably be a better abstraction.

Hence cell-level resource managers will need to deal with more than just containers and consider leveraging networking equipment as well when allocating resources for a workload.

Note that even today this is partially approached by existing resource managers and distributed systems through concepts such as node / rack locality. The assumption here is that networking resources will be richer at a node level than at rack level and rack level connectivity is richer than across racks, etc. This is mostly true for classical networks that assume good N-S bandwidth and less good E-W bandwidth due to the fact that nodes in two racks may need to communicate to a higher level switch that is shared across many switches, hence with limited bandwidth.

Metal Cell network architecture will involve E-W network links so racks could talk directly to each other, hence improving the E-W traffic. 

With this in mind a stronger abstraction to measure network communication bandwidth and latency will likely be needed.


### Global-Level Resource Management
A cell is by designed constrained to a single physical location (datacenter).
A cell is also an availability zone so we can think in terms of cell availability.

To increase availability a workload could target multiple cells, potentially across geographical locations.
While the stateless or semi-stateless (think in-memory content) workloads are relatively easily relocatable, for persistent state (e.g. in HDFS) replication needs to be considered. 

There are data consistency aspects involved, however we'll rather focus on the resource management aspect.

Just as the cell resource management needs to deal with shared network resources, communication between cells needs to tackle the problem in a similar fashion. 

Fundamentally there's no difference between intra-cell and cross-cell resource management. The only difference is in the capacity. Hence a global view of the resources is not only possible, but highly probable.

This will make the Metal Cell "brain" omnipresent. 

### Fine-grained ultra-granular application-level resource isolation
In the opposite extreme of the global view is the micro-level view of a computation.
Lightweight threads Fibers/coroutines 

Performance Monitoring and Debugging
---------------------------------------------------------

One of the main concerns in shared environments is related to the potential performance impact and the traceability and attribution of performance issues. 
This is a fair concern, given that the hardware is shared and and potentially overcommitted. 

Monitoring is intrinsic to Metal Cell, so core services are implicitly monitored.

Containers (through their standard interface) make it possible to implicitly monitor application-level workloads as well as.

* [cAdvisor](https://github.com/google/cadvisor) provides container resource usage and performance characteristics information. 

### Monitoring Infrastructure 

### Distributed Tracing
In addition a set of distributed dynamic tracing technologies will be available to get realtime deep visibly into fully distributed running systems.   

By integrating performance tracing libraries (HTrace, NativeTrace*) applications could get implicit performance tracing.


Layers
---------
A good understanding of various layers* and components of the Metal Cell is useful in order to understand  development practices.

We follow the terminology used in the "Datacenter as a Computer" paper published by Google that introduced the concept of Warehouse Scale Computers (WSC) that essentially make an entire date center behave as a single entity. The ***cell*** in Metal Cell follows the same model.


###Platform-level / Node Level

The scope of the infrastructure-level software is limited to a physical device. The firmware, drivers, kernel, operating system and clustering agents are at infrastructure level.

![Node](http://goo.gl/VU8rfH)  


####???
Resource isolation 
The low level 


###Cluster-level

![Cell](http://goo.gl/gjbHZj)


####What makes a service a cluster-level core service vs an application-level software?
Cluster-level services are managed services that are meant to be shared across workloads that run alongside.
The ability to share a service across several workloads implies at least a basic level of resource management within the service (think about security,  quotas and QoS).  

Examples:

* Hadoop Map-Reduce is such a service for example.
* Apache Kafka not so much (although it may become one).


#### Storage
* Unstructured (block) - file system
* Structured: databases 
* Streams: queues

#### Compute
* Raw: cores, ram, io: Mesos/Yarn,  Marathon,  Aurora
* Frameworks: Spark, Map-Reduce, Weave
* Hybrid: Storm

#### Service Configuration and Discovery
Consul, Etcd, Zookeeper
#### Coordination
Zookeeper, 	
#### Resource Management & Scheduling
Mesos, YARN
#### Monitoring

#### RPC 



###Application-level
Application level software is generally meant to provide functionality for our end-users. Most client-facing software is in this category.

*Note that each layer could actually be viewed as a collection of layers as well.

Datacenter Geography: Data Locality
---------------------------------------------------

Cell geography is information related to the physical environment of the cell. 

It's important to understand what the input, storage (if any) and output of any data is regardless whether this relates to a client data import or normal HTTP servicing. 

While we abstract most of the complexity of the underlying infrastructure through the cluster-level software we need to maintain control over some of the qualitative aspects. *Latency* and *Bandwidth* are two of the most important aspects that determine the performance and user experience and they need to be taken into account regardless of which the layer we're developing against is.

The actual physical latency and bandwidth parameters of the equipment are (generally) fixed (10GE network or 7200 RPM disk,  etc.). However,  the current load or the *Data Locality* are variable aspects that influence the latency and bandwidth.

Hence the physical the node, rack, pod or datacenter location of a process as well as the utilization of the shared resources (nodes, switches, routers, firewalls)  is important. 

Bridging Geography and Computational Complexity
------------------------------------------------------------------------

While forcing all the computation local to the input source may seem the best candidate, this is not always possible for several reasons.

**Uneven distribution of "orthogonal" resources**
While we may have a 10GE network card on a node, it's possible (and probable) that we won't have enough computing power available. 

A related scenario is that of data storage, that can't happen only on the local node. 

**Computational complexity**
The fork/join (or map/reduce) computation requires data that from potentially separate inputs to be available in the same reduce/join process.

Managing State
----------------------


Implementation
=============

Given the speed at which open-source evolves, relying on proprietary technology (in-house or 3rd party) is risky.
For this reason Metal Cell's goal is to leverage open-source technology* as much as possible.

###Infrastructure Level

#### OS
We're currently targeting CentOS 7 as a base for the Metal Cell

This said, as we're looking at leveraging container technology as well as cluster-level services for most workloads the host OS is likely to need much less than a classical server OS. 
Also, other features that may not be available in most common distributions or OS-es today may be needed.
Hence we're exploring alternative distributions such as CoreOS.

Within a cell it should be possible to run multiple OS es however. 

Deploying the OS.
[OpenStack Ironic](https://github.com/openstack/ironic) may be used to deploy the base OS.

#### Clustering software
On top of the OS there are the building blocks for the core cluster-level services

Container support:
[Docker Daemon](https://docs.docker.com/articles/basics/)

Cluster software agents
[Mesos Slave](http://mesos.apache.org/documentation/latest/mesos-architecture/)
[YARN Node Manager](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html)

As many of the cluster level services that we're running are not (yet) containerized and designed to run on a cluster manager,  we'll likely run some outside of containers initially.

###Cluster-level Infrastructure Software

#### Resource Management & Scheduling

**Resouce Management**
* [Mesos](http://mesos.apache.org/)
* [YARN](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html)

Note that Mesos and YARN have similar goals. While YARN comes from the Hadoop world and is backed by the Hadoop community along with companies such as Hortonworks and Cloudera.
Mesos comes from an academic environment, namely Berkleys' AMPLab which Adobe is also a member of and bears higher similarity with systems present in Google.
While there's probably more enthusiasm around the Mesos ecosystem (also due to Spark which was initially built as a Mesos demo use-case) the Hadoop ecosystem comes with an enterprise view of things that enables integrated enterprise-grade security and interoperation with existing Hadoop ecosystem services.

**Scheduling**
Long running 
* [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes)
* [Marathon](https://github.com/mesosphere/marathon),
* [Aurora](http://aurora.incubator.apache.org/)

Both Marathon and Aurora have similar goals.

Batch Scheduling
* [Khronos](https://github.com/airbnb/chronos)

#### Programming Frameworks
Note that is common for some systems to have their own schedulers

Job based
* [Hadoop Map Reduce]()
* [Spark](), [Impala], [Presto], [Drill]()

Long running frameworks
* [Storm]
* [Spark Streaming]
* [Samza]

#### Storage
Unstructured (block) - file system
* [Hadoop HDFS](http://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
Structured storage:
* [HBase](http://hbase.apache.org/)
Streams: queues
* [Kafka](http://kafka.apache.org/) (cluster sharing is limited)


#### Distributed Coordination,  Consensus, Synchronization
* [Zookeeper](http://zookeeper.apache.org/)(service)

Note that while zookeeper itself is a service, distributed coordination can be implemented with embedded libraries (there's a plethora using Raft http://raftconsensus.github.io/) 

#### Distributed Active Configuration and Service Discovery
* [Consul](http://www.consul.io/)
* [Etcd](https://github.com/coreos/etcd)

Note that Consul and Etcd are highly overlapping in some aspects.
Both provide REST APIs, Consul also provides a DNS interface and works across data centers.
It's likely that we'll test both and choose or potentially use both if that makes sense.

#### Distributed Performance Monitoring, Dynamic Tracing
* [OpenTSDB](http://opentsdb.net/)
* [Zipkin](http://twitter.github.io/zipkin/)

#### Distributed RPC 
TBD - see Standard Service Contract
* [Thrift](https://thrift.apache.org/)
* 

### Supporting technologies


Containers:
Docker 
Kubernetes 
CAdvisor
libswarm
libcontainer

Coordination
Raft
RPC

Encoding
Protocol Buffers
Avro 

Parquet 

Active Configurations
Adobe PrefX

Tech choices
-----------------

While the concepts employed in the Metal Cell are fairly stable, many of the technologies and patterns used are new and evolving.
While Big Data used to be super computing years ago and then became synonym with Hadoop the current ecosystem is much more diversified and there's no reason to believe it won't become even more diversified.

While we used to be looking at the Hadoop as a single system, the Hadoop ecosystem now contains a large set of technologies (we call these HSTACK). Hadoop has got enterprise notoriety through a consolidated community effort, however, just like linux it evolved organically and heterogeneously. Suffice to say that in terms of the code base there's a lot of legacy. 

In the meantime new systems have evolved from the open-source and academic communities. One of them is Mesos which is a product of Berkley's AMPLab (along with Spark, MLib, Tachyon,  etc.) 

CoreOS has built a new "cloud-optimized" OS based on Chromium OS along with new technologies that enable distributed services such as Etcd, Fleet, etc. 

Vagrant has been quietly working on Serf and Consul.

More recently Google has intensified it's involvement in the open-source space and started contributing as well, so we see Kubernetes - a container cluster scheduler along with cAdvisor and others. 

While we think the overall Metal Cell architecture won't change significantly we should be open to changing technology stacks. 

* both hardware and software
Developing for the Cell
===================

Writing application for 

Any software can run on the Metal Cell, including legacy software.
This being said, software that targets Metal Cell will be faster to write in a highly available, performant manner.

Identify the Layer
--------------------------

While this may seem obvious, identifying the actual layer may be tricky. This being said, a good enough understanding should be good enough to start with. 

Configuration
-------------------
There are two types of configurations an application may need:
* **Environment configuration** - endpoints, services that the application needs to communicate with (distributed file system, databases, message queues, etc.)
* **Application configuration** - buffer sizes, internal message queues, database tables, etc. These form the application-scoped context. 

Both these configurations could be solved with a configuration and discovery service (e.g. based on Consul/etcd or Zookeeper)

When deploying an application, the **environment configuration** should be available already and **application configuration** should be seeded (potentially from some application defaults and/or derived values based on the application container configuration (e.g. if container has 2GB RAM, we may want to have some derived values from that value) .

Packaging
--------------
Different application packaging may be required based on the layer(s) the application is targeting. 
For the infrastructure layer there may be firmware (e.g. `.bin`) files or OS specific package s(e.g. `.deb`, `.rpm`) .  

Higher cluster-level applications could be packaged in a containers (e.g. docker) that could be run on top of cluster resource managers (e.g. YARN/Helix, Mesos/Marathon/Deimios based managers).

Cluster-level, framework-specific applications (e.g. MR jobs, Storm topologies, etc.) come with their own packaging. 

Standard Service Contract
------------------------------------
The Standard Service Contract ensures that all applications will expose information such as version, state, endpoints in a standard manner that could be implicitly read from outside.

In addition these need to clearly, distinctively manage state. Volatile (in-memory) state should losable. Any state that should not be lost should be stored in a cluster level service that could withstand failures.

Services that obey the standard service contract should be easily scalable in a automated fashion and will offer a high degree of resilience. These services could be implicitly monitored without explicit operations and their sanity could be implicitly evaluated as well. 

Performance Tracing
-----------------------------
By integrating the standard performance tracing libraries (HTrace, NativeTrace*) applications will get implicit performance tracing 

Workload Types
----------------------

There are many dimensions a workload could be characterized from. Probably more than we would afford to expose here.

**Duration**
Long running
On-time/Recurring

**Layer**



Examples
-------------

**Edge collection**
Consider an event collection service with a HTTP API. The characteristics of such a workload are:

 - stateless
 - long running
 - network I/O intensive
 - cpu intensive 


Such a service could for example use existing open source technology such as [nignx](http://wiki.nginx.org/Main) and a series of plugins.
It could be packed in a container (https://github.com/orchardup/docker-nginx).

Then it could be run on top of [Marathon](https://github.com/mesosphere/marathon).
The edge layer should do a basic processing of the data and then route it to a designated queue. The queue information could be retrieved from the cluster service discovery (e.g. GET http://config/edge/output-queue or
through DNS output-queue.edge.config).
The edge workload manager should be able to negotiate with the resource manager (e.g. Mesos or YARN) about the container resources (e.g. 2 cores, 512MB RAM per process) and about the task placement (e.g. < 5 processes per node and < 50 per rack).  

Based on the ***Standard Service Contract***, the edge service should expose it's status, version, configuration,metrics and allow for start/pause/shutdown operations directly over it's standard API (HTTP, Thrift, etc). 
e.g.

```
GET http://edge-container-url:port/status
{"status":"ok"}
GET http://edge-container-url:port/config
{"output-queue":"kafka://kafka-container1,..,kafka-containerN:9099/edge-topic"}
```
At the same time, all containers will register themselves as the edge-service in the service discovery system. 

**Cell Interaction**
```
[<clehene@clehene-osx>][~]brew install cell 
[<clehene@clehene-osx>][~]cell list-resources --all
LON1-H1 available 48435/80000 cores,  84TB/132TB RAM 
...
OAK1-H1 available 48435/80000 cores,  84TB/132TB RAM 
OAK1-H2 available 48435/80000 cores,  84TB/132TB RAM 
OAK1-H3 available 48435/80000 cores,  84TB/132TB RAM 
...
SIN1-H1 available 7200/7200 cores,  37TB/37TB RAM 

[<clehene@clehene-osx>][~]cell list-tasks --cell=SIN-H3

[<clehene@clehene-osx>][~]git clone https://git.corp.adobe.com/mcloud/moa
[<clehene@clehene-osx>][~]cd moa/cells
[<clehene@clehene-osx>][~]cat cell.yaml
docker-registry: https://gauntlet-registry/
cell-uid: moa-dev
cell-key: ~/.cell/id_dsa
...
[<clehene@clehene-osx>][~]cat containers/small.yaml
cores: 2
ram: 2GB
[<clehene@clehene-osx>][~]docker search moa
NAME                  DESCRIPTION               STARS       TRUSTED
moa-api               CRS HTTP APIs             30          [OK]
moa-stream-loader  	  CRS Stream Ingestion      47          [OK]
moa-bulk-loader  	  CRS Stream Ingestion      12          [OK]

[<clehene@clehene-osx>][~]cell deploy --type=docker moa-stream-loader --containers=400 --cell=SIN1-H1
Task URL: http://cell/SIN1-H1/task/moa-stream-loader
Progress 168/400
Progress 400/400

[<clehene@clehene-osx>][~]cell list-resources --cell=SIN1-H1
SIN1-H1 available 6400/7200 cores,  37TB/37TB RAM 

```




Existing Metal Cells
================
Development Cells:
Production Cells:


Deploying the Cell
===============
Metal Cell is designed and optimized to take advantage of the datacenter hardware whenever possible by leveraging data locality at process, disk, node and rack level. 
This being said, the actual software can run on virtualized infrastructure without any functional problems. 

Developing the Cell
================

Metal Cell is part of [Adobe Open Development Initiative](https://wiki.corp.adobe.com/display/opendev/Home), hence developed in an Adobe internal open-source manner. 
This being said, Metal Cell si more about integrating existing open-source projects and having them available as readily available services in our data centers. 

There are several aspects of Metal Cell development:

HStack - Upstream OSS Projects Integration
-------------------------------------------------------------

Infrastructure
-------------------
This deals with Adobe's infrastructure abstraction (e.g. CMDB integration)

DC Blueprint 
--------------------
Physical and Virtual nodes deployment of the core pieces of Metal Cell 

DC Conductor - Datacenter Orchestration
----------------------------------------------------------


Roadmap
========

#### Metal Cell 0.9.1 (currently in production, a.k.a. SaasBase - Deployment project)
* Puppet Module Registry
* Monitoring and Alerting
*  TBD

#### Metal Cell 1.0 (resource isolation, service discovery, orchestration)
**Resource Isolation**
* Docker support 
* Docker registry
* Mesos, Marathon, Kubernetes, Kronos along with YARN
**Service discovery and active configuration services**
* Atlas (service discovery) using either etcd or consul 
**Orchestration**
* Bare metal OS bootstrap - OpenStack/Ironic 
* service level orchestration template
* Metal Conductor
**Console**
* API 
* UI
* CLI
**Tracing, Monitoring and Alerting**
*  cAdvisor
*  HTrace (Java Only) 
#### Metal Cell 2.0 (XDC realtime workload migration, network flow control)

Related
======
* OpenStack
* VPC
* Popcorn


History
======

Metal Cell got born out of learnings from years of running Hadoop, HBase, Zookeeper, Storm, Kafka and other in production for the SaasBase Analytics Project.   
Planing new deployments - choosing hardware, automating deployments, doing performance and failover testing, over and over again has led to the standardization of concepts and practices around distributed technology. There's a new technology popping up every week at least and making choices is not always easy. Sometimes the best setup is on one technology sometimes on another and sometimes on both. However a proliferation of software stacks generally leads to a proliferation of hardware profiles and deployments and teams and it can lead to fragile infrastructure that further leads to fragile service to our customers. 



Reference
========
* [Platform Ecosystem Problem Statement](https://wiki.corp.adobe.com/display/omtrcache/The+Platform+Ecosystem)  
* [The future of the infrastructure is metal (cells) - Slides](https://www.dropbox.com/s/cw5a6bw9c7hhtvh/The%20Future%20of%20Platform%20is%20Metal%20%28cells%29.pptx)  
* [The future of the infrastructure is metal (cells) - Video Analytics Mini-Summit Recording](https://my.adobeconnect.com/p3wea44zvb0/) @~ 00:21:40  
* [The Datacenter as a Computer: An Introduction to the Design of Warehouse-Scale Machines](http://www.morganclaypool.com/doi/abs/10.2200/S00516ED2V01Y201306CAC024)  
