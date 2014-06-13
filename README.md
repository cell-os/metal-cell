Title:       Metal Cell  
Subtitle:    Adobe's Mechanically Sympathetic Datacenter as a Computer
Project:     Metal Cell  
Author:      Cosmin Lehene  
Affiliation: Adobe  
Web:         httt://metal.corp.adobe.com  
Date:        June 2, 2014  
Misc:        The current version of this document lives in my stackedit.io - keep that in mind if you want to make any changes  

#Work in progress! Content and structure are subject to change!

Metal Cell
========
Metal Cell is Adobe's collaborative "Datacenter as a Computer" effort that attempts to move storage and computing from traditional, monolithic, multiple single-node setups to cluster and cluster-of-clusters using existing Open Source technology. 

"Exec Bullets"
--------------------------

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
* AZ
* Cell 
* Pods
* Racks
* Nodes


From a high-level (technical) perspective Metal Cell is concerns with 

* Abstraction/Layers (Time to Market)
* Resource Management (Efficiency)

Introduction Resource Isolation
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
You can imagine metal cell as a succession of layers similar to an onion (in 3 categories: infrastructure, custer, app).
Depending on the layer, orthogonal aspects such as resource isolation, compatibility, may have different concerns. For example at the OS level, the available resources (CPU, Memory, IO) are managed by the Linux Kernel. However, at the cluster level a higher level view that contains multiple running servers has a much bigger view that needs to factor in resources such as network equipment shared between servers (e.g. rack bandwidth and latency).


Resource Management and Isolation
----------------------------------------------------

### Infrastructure-Level Resource Management: Plumbing*

Although the resources may vary with each service, there are a few low level basic resources that matter.

At the infrastructure (device)-level, the main resources we're concerned with are CPU, Memory and IO * 

[footnote: as the server itself has it's own layers, internal subsystems such as network or disk controllers will have their own resource allocation and isolation semantics, however keep in mind that a layer is supposed to abstract wherever possible - think of virtual memoy for example. One could say that given the actual resources such as sillicon chips and energy things could be simplified, while we agree, we need to remain pragmatic]


#### Resource Isolation and Containers
To ensure SLAs when overcommitting resources a resource isolation mechanism is required.
For example the express line in your local store has an item-limit (generally less than 10-15). That's a good example of resource isolation to protect blocking the resource (cashier0 from a customer with 5 carts for example. 

Similarly operating systems have ways to ensure resource isolation. The Linux Kernel has cgroups[^cgroops-foot].  
and there are user-space interfaces to access the container features 

Layers
* [cgroups](https://www.kernel.org/doc/Documentation/cgroups/cgroups.txt)
* [Linux LXC](https://linuxcontainers.org/), [Google LMCTFY](https://github.com/google/lmctfy), [Docker libcontainer](https://github.com/docker/libcontainer)
* [Docker](https://www.docker.io)

For most standalone cluster level services, a Docker container should suffice.

#### Docker Containers


Resources
[cgroups redesign](http://www.linux.com/news/featured-blogs/200-libby-clark/733595-all-about-the-linux-kernel-cgroups-redesign)
[Linux Plumbers Conference](http://www.linuxplumbersconf.org)
[LMCTFY presentation](http://www.linuxplumbersconf.org/2013/ocw//system/presentations/1239/original/lmctfy%20(1).pdf)
[Containers RFC draft](https://github.com/containers/container-rfc)
[Google Embraces Docker](http://www.wired.com/2014/06/eric-brewer-google-docker/)
[Google CAdvisor](https://github.com/google/cadvisor)
[Google Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes)

### Cell-Level Resource Management
The computation unit is the *cell*. 

### Global-Level Resource Management


### Fine-grained ultra-granular application-level resource isolation
Lightweight threads Fibers/coroutines  TBD



Layers
---------

A good understanding of various layers and components of the Metal Cell is useful in order to understand  development practices.

Note that each layer could actually be viewed as a collection of layers as well.

###Infrastructure Level
The scope of the infrastructure-level software is limited to a physical device. The firmware, drivers, kernel, operating system and clustering agents are at infrastructure level.

####???
Resouce isolation 
The low level 

###Cluster Level

#### Storage
* Unstructured (block) - file system
* Structured: databases 
* Streams: queues

#### Compute
* Raw: cores, ram Mesos/Yarn,  Marathon,  Aurora
* Frameworks: Spark, Map-Reduce, Weave
* Hybrid: Storm

#### Service Configuration and Discovery

#### Coordination
#### Scheduling
#### Resource Management
#### Monitoring
#### RPC 


###Application Level
Application level software is generally meant to provide functionality for our end-users. Most client-facing software is in this category.

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

Performance Tracing
-----------------------------
By integrating the standard performance tracing libraries (HTrace, NativeTrace*) applications will get implicit performance tracing 

Workload Type
---------------------


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

#### Metal Cell 0.9 (currently in production, a.k.a. SaasBase - Deployment project)
#### Metal Cell 1.0 (resource isolation, service discovery, orchestration)
#### Metal Cell 2.0 (XDC realtime workload migration, network flow control)

Related
======
OpenStack
VPC
Popcorn


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
