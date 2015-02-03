Title:         Metal Cell  
Subtitle:    Adobe's Mechanically Sympathetic Datacenter as a Computer
Project:     Metal Cell  
Author:      Cosmin Lehene  
Affiliation: Adobe  
Web:          httt://metal.corp.adobe.com  
Date:         June 2, 2014  
Updated:   Feb 3, 2015


*Metal Cell is Adobe's collaborative "Datacenter as a Computer" effort that attempts to move storage and compute from traditional, monolithic, multi single-node setups to homogenous pools of resources (cells) using existing Open Source technology.*

Notes for the reader
================

**Work in progress!**
The actively edited version of this document lives in my [stackedit.io](https://stackedit.io/).
Keep in mind that it's being updated so stuff may get moved, rephrased or deleted and new stuff added. Also there are "loose" ends and incomplete parts. Some may be intentional some accidental.
If you have suggestions, changes, etc. you can email me or send them through pull requests. See the [open-development contribution guide](http://saasbase.corp.adobe.com/guides/saasbase_contributors.html).

**Beware of the Metal Cell "duality confusion"**
"Metal Cell" is referred to both as an ***abstract concept/approach/philosophy/vision*** related to how general computation can be done at scale along with the software development lifecycle in such an environment, as well as a ***concrete system*** with a concrete hardware and software architecture. While we may refer to the actual software stack with a different name in the future, "Metal Cell" is currently used to refer to both. Keep that in mind to avoid getting confused.

**Rationale**
The rationale for *this document* is to apply  some [reusability](http://en.wikipedia.org/wiki/Reusability) concepts to "knowledge" that has been generally fragmented and repeated over emails, wikis and sometimes blog posts. It's an attempt to give a cohesive view of disparate but, after all, interrelated aspects of distributed systems, and show how a concerted approach to systems at scale can work.

**Community**
The "concrete system" implementation is an Adobe community effort and follows [Adobe's Open Development Principles](https://wiki.corp.adobe.com/display/~bdelacre/Open+Development+Principles).   Discussions happen on public mailing lists, code is accessible in the internal Github repos and issues are tracked in the Adobe official JIRA.

While there's a planned roadmap, the dates are mere desires so if you need something that's not there or you need it earlier consider discussing it in the community and potentially contributing to it. What we'll try to do as a community is offer the "framework" in which such work happens in the best possible way for you and with the best possible outcome in terms of quality and time.

**Developer mailing list**: DL-metal-cell-dev@adobe.com (alias metal-cell@adobe.com)  

**Users mailing list**: DL-metal-cell-users@adobe.com  

**Github**: https://git.corp.adobe.com/metal-cell/  

**JIRA**

* https://issues.adobe.com/browse/CELL
* https://issues.adobe.com/browse/HSTACK

**Docs**: 
* https://git.corp.adobe.com/pages/metal-cell/metal-cell/  
* https://git.corp.adobe.com/metal-cell/metal-cell/wiki/


Abstract
=======

Getting new products from whiteboards to paying customers often involves more effort for integration,  automation, performance and reliability testing, etc. than for the actual software development. 

Just the cost of reliability can exceed that of actual development. And, in spite of a large effort and the actual quality of the code, reliability expectations may still not be met. However, customers pay for functionality and expect reliability to be part of it.

The rate at which new "big data" technologies become available has increased in the last few years to a level where it seems that there's a new technology that promises to change everything comes up every week. Keeping track and making informed decisions can be daunting. 
As an effect we witness a proliferation of software stacks and hardware configurations and, as a result, an increase in *system complexity*. 
Thus, development and operations teams need to manage more complexity (sometimes more than they can handle). 
This can lead to fragile infrastructure that further leads to fragile services and, eventually, unhappy customers.
It gets further exacerbated by acquisitions which add to the overall complexity, while customers increase their expectations for smooth integrations across the products and expect the promised magic of "the cloud".

At the same time, as the "cloud effect" has led to a "democratization of big data", we see an increased speed of innovation from small, agile startups in areas that were traditionally accessible to large enterprises only. 
In contrast, large enterprises have a legacy of existing technology, products and customers that comes at a cost that reflects into time to market, overall cost and agility.

Most times, however, it's just the product or the feature that differs in an overcomplicated process that may involve redundant infrastructure, processes etc.  
Yet we still tend to solve the whole problem, again and again and end up with "deep monoliths" - products along their *unique* infrastructure, processes and teams to support them. Each product has it's own cluster, own technology stack, own team that manages up everything from the bottom infrastructure-level up to the application-level.

Most of the above aspects could be part of a *reusable platform* but it's not immediately obvious how and it can be hard to solve in practice without having "the whole big picture" first. 

Metal Cell is that "big picture". 

It got born from years of learning from years of experience with open-source productization, integration, development, and operation of distributed systems in conjunction with industry and research literature.
One of the most influential papers has been the "The Datacenter as a Computer - An Introduction to the Design of Warehouse-Scale Machines" by Google's Luiz André Barroso and Urs Hölzle. 

Metal Cell attempts to bring that in the reality of our own datacenters, the clouds and the existing and in progress open-source software.


"Exec Bullets"
--------------------  
* **Improved time to market** through accelerated development and self service provisioning of both infrastructure (IaaS) and cluster level services (PaaS)
* **Reliability** through redundancy, high availability and linear scalability of every layer in the stack
* **Cost efficiency** through consolidated infrastructure and resource sharing that could reduce the hardware footprint by 10x(.


The goal of Metal Cell is to improve products ***time to market*** and increase ***reliability *** and ***cost efficiency***.  It achieves this by applying a "disaggregation approach", to systems, breaking monolithic architectures into shared, self-service cluster-level services. (To some extent this can be compared to how operating systems abstract some of the hardware complexity and make common services available for the user-level software.)

Thus, the ***cell***  becomes the "new box" and the software running on it acts like a loosely coupled "operating system". However, software that target the *cell* can take advantage of a much larger pool of resources (potentially spanning 10000s of nodes) as well as directly benefit from built-in resiliency to failures, traffic spikes, etc.

The Cell "OS" is made of highly available distributed services that provide:

* Resource (storage, compute, IO) management (isolation, allocation, scheduling)
* Storage (block, structured, queue)
* Compute (raw resources such as cores, RAM, IO)
* High Level Computing Frameworks (batch, event, streaming)
* Monitoring and Alerting

Concretely, the Metal Cell *software stack* integrates and builds on top of well known, open-source software such as Hadoop, Spark, Mesos, Docker, HBase, Zookeeper, etc. and exposes it as readily-available, integrated services that development teams could use as self-service, shared resources across data centers and clouds.

**Mechanical Sympathy**
We can only abstract, but not make go away, things like speed of light, latency, bandwidth, etc. For this reason we should not hide them underneath [APIs that are supposed to make them look like running on a single machine](http://writings.quilt.org/2014/05/12/distributed-systems-and-the-end-of-the-api/).
Rather than oversimplifying and hiding the complexities of distributed systems, Metal Cell, instead, distills them. While solving some of the common problems of distributed systems (storage, compute, scheduling, etc.), it abstracts, but not hide, their complexities and keeps them transparent to developers, so that applications can be written in a responsible manner in relation to them. 

Motivation
=========

Time to Market
------------------
Reduce new applications turnaround time from months to days enabling continuous delivery.

Current practices involve teams that code, deploy and operate full stacks. With the proliferation of distributed systems, these stacks may involve more than 10 different services, making development and operations complex. Many times more time ends up being spent in setting up and maintaining development environments - integration with all components, dealing with versions conflicts, etc. than on the sellable product. 
	
*Note: More, when releasing these systems to production, there's an assumption that these could be simply "handed over" to operations teams. However, in reality the "hand-over" process can be a long and sometimes impossible to happen as expected.

This is to some extent improved in cloud environments as general purpose functions such as storage or computing may be available "as a service" (*AAS), however the unit of computation still is the "machine" and implications of integrations between several products are impossible, more than from a security / access level perspective. 

By developing applications and services against cells (benefiting from the cluster-level services) we are able to decouple a lot of the distributed systems complexity from the application logic. Self-service provisioning enables developers to run applications against existing clusters. This reduces the development time substantially and at the same time changes the unit of computation from a *machine* to a *pool of resources* (a cluster of machines).

Provisioning and deployment become a matter of consuming a service so time to market is further reduced[ see Marathon, Aurora, Kubernetes].

By relieving development teams from this overhead more time can be spent on developing software with direct business value.

Many times we face a "chicken-and-egg problem" when it comes to new services. We need the infrastructure to estimate performance but we wait to be ready with software in order to order it. 
Being able to "tap" into resources in existing infrastructure across data centers and public cloud would solve this. Also by sharing the infrastructure the cost is amortized across more products (see "cost efficiency").

Lean hardware provisioning
We decouple hardware provisioning and product delivery, essentially removing the hardware provisioning from the critical path. There's always spare capacity to start a new project, and the additional capacity adds more resources for everyone. 


Cost Efficiency
-----------------
Benefits from economy of scale should allow us to reduce our hardware footprint by 10x and decrease operational overhead substantially.

The infrastructure load in typical datacenters (as in Adobe's) is between 1% and 10% (normally skewed towards 1%).
Unfortunately a physical node consumes ~50% of the total energy when idle. By collocating workloads we can increase hardware utilization rate substantially (highly efficient deployments get above 60% utilization).

By using resources more efficiently and by concentrating more compute and storage capacity within the same space we can reduce the hardware footprint. Note that hardware footprint doesn't translate proportionally to costs so this should not necessarily be projected in a 10x cost reduction.

Inefficiencies of Monolithic Systems Architectures
Configuration items proliferation
Traditionally services are deployed in a *monolithic* fashion with a standard deployment containing dedicated machines (aka roles) for web servers, database servers and others.
This is energy inefficient and results in fragmented environments due to service-dedicated hardware profiles, os-es, software versions and operations teams. 
Operation teams need manage all this complexity and also need to have a broad enough skill set to support the entire variety of the stack being used. Expertise over such a broad set of technologies is hard to achieve in practice by single teams that are dedicated for products. Generally this comes at higher costs and decreased reliability.

By consolidating on shared infrastructure less hardware profiles (generally 2 or 3 vs 10s) need to be used. This means less complexity to manage and debug but also improved discount rates from vendors, a larger pool of spare parts, etc. Nevertheless, it also removes the burden of hardware profile selection from product teams, that can now  model their expected load against a shared pool of granular resources (e.g. compute, memory, IO).

A similar effect is gained from consolidating the software stacks, starting from OS to the cluster-level software so operations teams now can focus on less, larger deployments, allowing creation of a "layer-based" expertise, essentially enabling sharing of the operations teams across different products. 

In order to accommodate traffic spikes, infrastructure is generally provisioned with a sizable "buffer". For some workloads spikes can be 10x of the normal traffic, so a large quantity of servers are dedicated to be idle for most of the time.
By sharing a larger infrastructure the additional capacity is much larger and can be both shared between multiple workloads and used in off-peak times.

By sharing infrastructure between workloads we could achieve a much higher compute efficiency. Also compute efficiency can now be measured uniformly accross an entire fleet along with all running workloads opening new optimization possibilities like [leveraging non-used cycles and cheap energy](http://googleblog.blogspot.ca/2014/05/better-data-centers-through-machine.html)


Reliability 
------------
(Chapter in progress)

Technical
* fault tolerance
* high availability
* scalability

Human:
* layer based expertise
* 
Reliability depends both on technical and human factors.

Metal Cell Concepts/Terminology
============================


World view
-------------

There's a lot of complexity in today's systems that may involve multiple geographically distributed datacenters along with local and global networks that connect nodes, racks, etc.

###"physical"* scope hierarchy
[^footnote Using quotes for "physical" as cell is actually a logical construct on top of some physical entities a physical analogy would be a cluster]

* Global (the collection of all cells across the globe)
* Region
* Cell
* Pods
* Racks
* Nodes
* Containers
* Processes
* Threads

----------------
###Global / Regions
```                                                                 
                                                                              
     +-------+   +-------+         +-------+  +-------+         +-------+     
     |       |   |       |         |       |  |       |         |       |     
     | US-W  |   |  US-E |         | EU-W  |  |  EU-E |         | AP NE |     
     |       |   |       |         |       |  |       |         |       |     
     +-------+   +-------+         +-------+  +-------+         +-------+     
                                                                              
                                                                              
           +-------+                                          +-------+       
           |       |                                          |       |       
           |  SA   |                                          | AP SE |       
           |       |                                          |       |       
           +-------+                                          +-------+       
   
```

### Region / Datacenter  / Cells

```
+---------------------------------------------------------+
|   +power             +power             +power          |
|   |                  |                  |               |
|   |    +network      |    +network      |    +network   |
|   |    |             |    |             |    |          |
|  ++----+-------+    ++----+-------+    ++----+-------+  |
|  |             |    |             |    |             |  |
|  |             +----+             +----+             |  |
|  |  OR1-CELL-1 |    |  OR1-CELL-1 |    |  OR1-CELL-1 |  |
|  |  A: 99.95%  |    |  A: 99.95%  |    |  A: 99.95%  |  |
|  +-------------+    +-------------+    +-------------+  |
|                          OR1                            |
+---------------------------------------------------------+

```

### Cell

```
            +--+Power circuit                                                 
            |                          +--+ Network                           
            |                          |                                      
        +---+--------------------------+---------------------+                
        |                                                    |                
        |  +---------------------------------------+         |                
        |  |                                       |         |                
        |  |  +---------+-----------+              |         |                
        |  |  |         |           |              |         |                
        |  |  +-----+   +-----+     +-----+        |         |                
        |  |  |-----|   |-----|     |-----|        |         |                
        |  |  |-----|   |-----|     |-----|        +--+ ...  |                
        |  |  |-----|   |-----|     |-----|  POD+1 |         |                
        |  |  |-----|   |-----|     |-----|        |         |                
        |  |  |-----|   |-----| ... |-----|        |         |                
        |  |  +-----+   +-----+     +-----+        |         |                
        |  |  RACK 1    RACK 2      RACK 10        |         |                
        |  +----+----------------------------------+         |                
        |       |                                            |                
        |  +----+----------------------------------+         |                
        |  |                                       |         |                
        |  |  +---------+-----------+              +--+ ...  |                
        |  |  |         |           |              |         |                
        |  |  +-----+   +-----+     +-----+        |         |                
        |  |  |-----|   |-----|     |-----|        |         |                
        |  |  |-----|   |-----|     |-----|        |         |                
        |  |  |-----|   |-----|     |-----|  POD+3 |         |                
        |  |  |-----|   |-----|     |-----|        |         |                
        |  |  |-----|   |-----| ... |-----|        |         |                
        |  |  +-----+   +-----+     +-----+        |         |                
        |  |  RACK 1    RACK 2      RACK 10        |         |                
        |  +---+-----------------------------------+         |                
        |      |                                             |                
        |      +                                             |                
        |      ...                                           |                
        +----------------------------------------------------+                
                                                                              
```

### Node
```
+------------------------------------------------+
|                                                |
| +-------------------------------------------+  |
| |                                           |  |
| | +----------+ +----------+   +----------+  |  |
| | |          | |          |   |          |  |  |
| | |          | |          |   |          |  |  |
| | |Container | |          |...|          |  |  |
| | +----------+ +----------+   +----------+  |  |
| |  OS / Kernel                              |  |
| +-------------------------------------------+  |
|   Physical node                                |
+------------------------------------------------+

```

Onion Layers
----------------

Conceptually micro scale problems may have macro scale equivalents.
Going from a process level (small scale)  to a larger level like OS environment and then the cluster level (larger), we may need to worry about similar concerns, such as shared resource management, resource isolation or compatibility. However note the different *scopes* (and potentially different solutions) with each level of abstraction (layer).

Similarly to "Datacenter as a Computer" we refer to 3 broader categories:
* infrastructure / device / node
* cluster
* application

Each however may have it's own inner layers with equivalent concerns WRT resource consumption, resource sharing, capacity, etc.

The actual implications of this *scope* hierarchy can be subtle but broad. 

### Compatibility Layers: Binary vs Wire

Consider for example the *binary compatibility* problem which arises from a shared resource - the library. Most times it's a concern at the OS (node) level due to incompatibilities that may arise. For this reason we have versioning systems and package managers and package repositories, that attempt to solve the problem of dependency and compatibility.

At the cluster-level we recognize the same problem as *API compatibility* (or wire / protocol compatibility). It may be straightforward that the problem is at the same time very similar and that the solutions are very different. 

Think what an Linux distribution represents for example. There's usually a kernel, an init system, one or more filesystems along with a plethora of packages ranging from compilers to databases. A distro represents a "compatible aggregation" of all of the packages involved. The package manager is at the core, managing the complexity of dependencies. 
However, a package manager's scope is limited at the OS/node level and a cluster-level service could run on multiple nodes that have different versions of the OS, different distributions and even different OS-es (e.g. [SETI@Home](http://setiathome.ssl.berkeley.edu/)). Yet, cluster-level software like Hadoop is packaged into distribution specific packages (e.g. rpm, deb) and many shops try to manage versions through OS-level package managers.

However, consider what a package upgrade means. While perfectly viable from a binary compatibility perspective, a cluster-level service upgrade at the node-level (through yum or apt) could break a service level compatibility, corrupt data and, potentially bring havoc in a cluster. 

The package manager has a clear scope. Attempting to use it beyond it's scope is generally a bad idea.

There have been many attempts to solve this problem. More recent configuration management tools such as CFEngine, Puppet, Chef, Salt, Ansible and others are used to deploy software including cluster-level services. While we have been using some of them extensively, they offer an "intermediary" solution to the actual problem in that they still tackle the problem at a node level and lack robust abstractions required for distributed systems.

While Metal Cell uses some of these to bootstrap the minimal node-level software. This function becomes a concern of some cluster-level software. 

### Resource Management Layers
At an *OS level* the Kernel manages the local CPU cores, memory and IO resources.
At a *cluster level* there's a wider view of the resources which includes both servers and the networking equipment that may be shared across multiple workloads.

* 3 large layer categories: infrastructure, custer, app.

Resource Management
---------------------------

### Resource types and resource quantification
The variety of resources measures exposed by all devices may may be intimidating, but in reality, most can be quantified in terms of *capacity*, *bandwidth* and *latency*.

At the infrastructure (or device) level, the main resources we're concerned with are CPU, memory, disk and network[^resource-management-1].
*Capacity* (or space) is used for indefinite-time data storage resources (e.g. caches, RAM, SSD), while more stateless resources such as networking and compute can be measured in *bandwidth* and *latency*[^resource-management-2].

[^resource-management-1]:  as a generalization you can imagine just two/three type of resources: those that store and those that process and those that make it possible to transport data from storage to processing.  The measures that we'll mostly care about are *capacity*, *bandwidth* and *latency*.

[^resource-management-2]: as the physical node itself has it's own layers, internal subsystems such as network or disk controllers may have their own resource allocation and isolation semantics, along with OS or kernel level subsystems that deal with those. However, keep in mind that a layer is supposed to abstract the complexity underneath (e.g. virtual memory). 


### Resource Utilization 

Average resource utilization in industry is < 10% and skewed towards 1%

![Low utilization across a single workload](https://git.corp.adobe.com/metal-cell/metal-cell/blob/gh-pages/img/utilization%20-%20low.png)

There are multiple reasons for this, including the type of workloads, over-provisioning for peak load, etc. However a lot of this can be attributed to monolithic architectures.

Across an organization an aggregation of loads across different infrastructures from different products may look like this:

![Low utilization across an organization](https://git.corp.adobe.com/metal-cell/metal-cell/blob/gh-pages/img/utilization%20-%20across.png)

In contrast the resource utilization in Metal Cell can be much higher:

![Metal Cell Utilization](https://git.corp.adobe.com/metal-cell/metal-cell/blob/gh-pages/img/utilization%20-%20metal-cell.png)

(incomplete)

This is achieved by

* granular resource units
* granular resource isolation
* realtime cluster scheduling
* mechanical sympathy

####Workload types
**Organic growth and Daily, Weekly, Seasonal Load Variation**

####Over-provisioning
As we need to 

####Accidental over-provisioning


### Resource Oversubscription 

Economy of scale, resource utilization, resource sharing, etc.   

Imagine you'd have a store where each customer has it's own sales person.
That's generally nice, but also expensive (for both the store and the customer). Although there are stores like that (imagine an expensive watch store), generally the sales people are *oversubscribed* - hence they may serve more than one customer. *Oversubscription* has been used in computing for quite a while to enable multi-tenancy.  Multitasking is one way to share the CPU between multiple tasks, hence oversubscribing it. Oversubscription doesn't necessarily cause performance degradation, but it can if resources end up being *overcommitted*. [^footnote: there's a subtle difference between *oversubscription* and *overcommitment*. Airlines always *oversubscribe* seats on an airplane. It's only when they become *overcommitted* that this becomes a problem. That's usually when airlines will start bidding for seats.]

The checkout line at your local store is an example of performance degradation when your normal wait time will get degraded. 

Economy of scale will determine the efficiency. The larger the store is the less probable it becomes to either have un-utilized cashiers or unserved customers that wait in queue for too long.

Resource utilization optimization is a common problem. However, just as the local store may have an express line, we generally need to guarantee some resource quality of service (QoS). 


### Resource Isolation



#### Containers
To ensure QoS when sharing resources an isolation mechanism is required.

For example, the express line in your local store has an item-limit (generally less than 10-15). That's a good example of resource isolation to protect blocking the resource (cashier0 from a customer with 5 carts for example. 

In a similar fashion an OS provides mechanisms aimed to isolate resources.  
The Linux Kernel has namespaces and cgroups[^cgroops-foot] as building blocks to offer resource isolation.

**Resources**

* Namespaces and cgroups  
	* [namespaces](http://lwn.net/Articles/531114/)
	* [cgroups](https://www.kernel.org/doc/Documentation/cgroups/cgroups.txt)
	* http://www.haifux.org/lectures/299/netLec7.pdf
* Containers
  * [Linux LXC](https://linuxcontainers.org/), [Google LMCTFY](https://github.com/google/lmctfy), 
  * [libcontainer](https://github.com/docker/libcontainer)
  * [Docker](https://www.docker.io)
  * [App Container](https://github.com/appc/spec/blob/master/SPEC.md) Specification
  * [Rocket](https://github.com/coreos/rocket) (an App Container implementation from CoreOS)

#### Docker Containers
Docker is a container engine with the goal of aiding application packaging and running in lightweight containers. 

**Resources**
[cgroups redesign](http://www.linux.com/news/featured-blogs/200-libby-clark/733595-all-about-the-linux-kernel-cgroups-redesign)  
[Linux Plumbers Conference](http://www.linuxplumbersconf.org)  
[LMCTFY presentation](http://www.linuxplumbersconf.org/2013/ocw//system/presentations/1239/original/lmctfy%20(1).pdf)  
[Containers RFC draft](https://github.com/containers/container-rfc)  
[Google Embraces Docker](http://www.wired.com/2014/06/eric-brewer-google-docker/)  
[Google CAdvisor](https://github.com/google/cadvisor)  
[Google Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes)  


### Resource Scheduling




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
A cell is also a failure domain (or availability zone) so we can define a measure of availability for the cell.

To increase availability a workload could target multiple cells, potentially across geographical locations.
While the stateless or semi-stateless (think in-memory content) tasks are relatively easily relocatable, for persistent state (e.g. files, or a database) replication needs to be considered. 

Although there are also data consistency aspects involved, we'll focus on the resource management aspect.
Just as the cell resource management needs to deal with shared network resources, communication between cells needs to tackle the problem in a similar fashion. 

Fundamentally there's no difference between intra-cell and cross-cell resource management (the differences are in the capacity, bandwidth and latency), so a global view of the resources is possible.

### Fine-grained ultra-granular application-level resource isolation
In the opposite extreme of the global view is the micro-level view of a computation.
Lightweight threads Fibers/coroutines 


Performance Monitoring and Debugging
---------------------------------------------------------

One of the main concerns in shared environments is related to the potential performance impact and the traceability and attribution of performance issues. 
This is especially important when resources are oversubscribed.

Monitoring is intrinsic to Metal Cell, so core services are implicitly monitored.

Containers (through their standard interface) make it possible to implicitly monitor application-level workloads as well as.

* [cAdvisor](https://github.com/google/cadvisor) provides container resource usage and performance characteristics information. 

### Monitoring Infrastructure 

### Distributed Tracing
In addition a set of distributed dynamic tracing technologies will be available to get realtime deep visibly into fully distributed running systems.   

By integrating performance tracing libraries (HTrace, NativeTrace*) applications could get implicit performance tracing.

Security
-----------
TBD

Resources:
Docker:
http://www.projectatomic.io/blog/2014/09/yet-another-reason-containers-don-t-contain-kernel-keyrings/  
Hadoop:
http://hadoop.apache.org/docs/r2.3.0/hadoop-project-dist/hadoop-common/SecureMode.html  
Mesos:
http://mesos.apache.org/blog/framework-authentication-in-apache-mesos-0-15-0/  
Knox:
http://knox.apache.org/  


Mechanical Sympathy: Layer Transparency and QoS 
--------------------------------------------------------------
We often relocate software workloads from one platform to another. However distributed infrastructure software is generally optimized based on some assumptions about the underlying hardware and software. For example HDFS replicates each block 3 times and places each replica differently: 1 replica on the local node, 1 replica on different node within the same rack and another replica outside of the rack. The assumptions here are that the local node will have the best latency and bandwidth (by not having to go through a network hop), a node within the same rack is still reachable at a high bandwidth (directly through the top-of-the-rack switch (ToR) ), hence the data block can withstand a node failure and maintain integrity, but in order to withstand a full rack failure (due to failure of the ToR or power circuit) the 3rd replica is outside of the rack. Notice that these are assumptions about the bandwidth, latency, storage capacity as well as the availability from a failure perspective of each of these components. 

Now think about the scenario where you run HDFS in virtualized infrastructure. Not only there's normally no knowledge about the physical location of each data block as we may have all datanodes allocated to the same physical host, but the actual location along with the failure probability, latency and bandwidth can change at runtime.  
[^footnote]: 
A more elaborate example is that of *resource scheduling*, *network uniformity*, *data locality*,  violation.

Metal Cell Layers
------------------------
A good understanding of various layers* and components of the Metal Cell is useful in order to understand  development practices.

Metal Cell follows the terminology used in the "Datacenter as a Computer" paper published by Google that introduced the concept of Warehouse Scale Computers (WSC).
The ***cell*** in Metal Cell follows the same model of making a large fleet of servers, potentially spanning an entire datacenter, be exposed as single pool of resources.

###Platform-level / Node Level Software

The scope of the infrastructure-level software is limited to a physical device. The firmware, drivers, kernel, operating system and clustering agents represent infrastructure level software.

![Node](https://git.corp.adobe.com/metal-cell/metal-cell/raw/gh-pages/img/meta-cell-node-150.png)

###Cluster-level Software

![Cell](https://git.corp.adobe.com/metal-cell/metal-cell/raw/gh-pages/img/metal-cell-cluster-150.png)


####Core/Shared services
Cluster-level services are managed services that are meant to be shared across workloads that run alongside.
The ability to share a service across several workloads implies resource management capabilities within the service (think about security,  quotas and QoS).  

**Examples:**
Hadoop Map-Reduce can support multiple jobs and allows for fine control of the resources allocated within the framework. Various schedulers can be used in order to prioritize, preempt or isolate tasks.

Apache Kafka on the other hand, while it does allow some semantics in terms of partitioning, has no isolation mechanisms, hence, one client could potentially saturate the cluster.


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

The actual physical latency and bandwidth parameters of the equipment are (generally) fixed (10GE network or 7200 RPM disk,  etc.). However,  the *system load* or the *data locality* are *variable* aspects that influence the latency and bandwidth.

Hence the physical the node, rack, pod or datacenter location of a process as well as the utilization of the shared resources (nodes, switches, routers, firewalls)  is important. 

Bridging Geography and Computational Complexity
-------------------------------------------------------------

While the extreme example of forcing all the computation local to the input source may seem the most efficient, this is not always possible due to either computational complexity or resource availability.

**Uneven distribution of "orthogonal" resources**
While we may have a 10GE network card on a node, it's possible (and probable) that we won't have enough computing power available to process a 10Gbps stream of data.

A related scenario is that of storage space limitations - e.g. the dataset may not fit on a single (data locally) node.

**Computational complexity**
The fork/join (or map/reduce) computation requires data that from potentially separate inputs to be available in the same reduce/join process.

Managing State
----------------------
TBD

Implementation
=============

Given the speed at which open-source evolves, relying on proprietary technology (in-house or 3rd party) is risky.
For this reason Metal Cell's goal is to leverage open-source technology* as much as possible.

##Infrastructure Level

### OS
We're currently targeting CentOS 7 as a base for the Metal Cell

This said, as we're looking at leveraging container technology as well as cluster-level services for most workloads the host OS is likely to need much less than a classical server OS. 
Also, other features that may not be available in most common distributions or OS-es today may be needed.
Hence we're exploring alternative distributions such as CoreOS.

Within a cell it should be possible to run multiple OS es however. 

Deploying the OS.
[OpenStack Ironic](https://github.com/openstack/ironic) may be used to deploy the base OS.

### Clustering software
On top of the OS there are the building blocks for the core cluster-level services

Container support:
[Docker Daemon](https://docs.docker.com/articles/basics/)

Cluster software agents
[Mesos Slave](http://mesos.apache.org/documentation/latest/mesos-architecture/)
[YARN Node Manager](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html)

As many of the cluster level services that we're running are not (yet) containerized and designed to run on a cluster manager,  we'll likely run some outside of containers initially.

##Cluster-level Infrastructure Software

### Resource Management & Scheduling

**Resouce Management**
* [Mesos](http://mesos.apache.org/)
* [YARN](http://hadoop.apache.org/docs/current/hadoop-yarn/hadoop-yarn-site/YARN.html)

Note that Mesos and YARN have similar goals. While YARN comes from the Hadoop world and is backed by the Hadoop community along with companies such as Hortonworks and Cloudera.
Mesos comes from an academic environment, namely Berkleys' AMPLab which Adobe is also a member of and bears higher similarity with systems present in Google.
While there's probably more enthusiasm around the Mesos ecosystem (also due to Spark which was initially built as a Mesos demo use-case) the Hadoop ecosystem comes with an enterprise view of things that enables integrated enterprise-grade security and interoperation with existing Hadoop ecosystem services.

**Scheduling**
Long running 

* [Marathon](https://github.com/mesosphere/marathon),
* [Kubernetes](https://github.com/GoogleCloudPlatform/kubernetes)
* [Aurora](http://aurora.incubator.apache.org/)

Both Marathon and Aurora have similar goals.

Batch Scheduling

* [Khronos](https://github.com/airbnb/chronos)

### Cluster Compute Frameworks
Note that is common for some systems to have their own schedulers

Job based

* [Hadoop Map Reduce]()
* [Spark](), [Impala], [Presto], [Drill]()

Long running frameworks

* [Storm]
* [Spark Streaming]
* [Samza]

### Storage
Unstructured (block) - file system
* [Hadoop HDFS](http://hadoop.apache.org/docs/r1.2.1/hdfs_design.html)
Structured storage:
* [HBase](http://hbase.apache.org/)
Streams: queues
* [Kafka](http://kafka.apache.org/) (cluster sharing is limited)


### Distributed Coordination,  Consensus, Synchronization
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


**Containers**:
Docker 
Kubernetes 
CAdvisor
libswarm
libcontainer

**Coordination**
Raft
RPC

**Encoding**
Protocol Buffers
Avro 

Parquet

Active Configurations
Adobe PrefX

Tech choices
-----------------

While the concepts employed in the Metal Cell are fairly stable, many of the technologies and patterns used are new and evolving.
While Big Data used to be called "super computing" years ago and then became synonym with Hadoop, the current ecosystem is much more diversified and there's no reason to believe it won't become even more diversified.

While we used to be looking at the Hadoop as a single system, the Hadoop ecosystem now contains a large set of orthogonal technologies (we call these HSTACK). Hadoop has got enterprise notoriety through a consolidated community effort, however, just like linux it evolved organically and heterogeneously. Suffice to say that in terms of the code base there's a lot of legacy. 

In the meantime new systems have evolved from the open-source and academic communities. One of them is Mesos which is a product of Berkley's AMPLab (along with Spark, MLib, Tachyon,  etc.) 

CoreOS has built a new "cloud-optimized" OS based on Chromium OS along with new technologies that enable distributed services such as Etcd, Fleet, etc. 

Vagrant has been quietly working on Serf and Consul.

More recently Google has intensified it's involvement in the open-source space and started contributing as well, so we see Kubernetes - a container cluster scheduler along with cAdvisor and others. 

While we think the overall Metal Cell architecture won't change significantly we should be open to changing technology stacks. 

* both hardware and software

Developing for the Cell
===================

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
[UT1-VCELL-3](https://git.corp.adobe.com/metal-cell/clusters/tree/master/UT1-VCELL-3)
Production Cells:


Deploying the Cell
===============
Metal Cell is designed and optimized to take advantage of the datacenter hardware whenever possible by leveraging data locality at process, disk, node and rack level. 
This being said, the actual software can run on virtualized infrastructure without any functional problems. 

Developing the Cell
================

Metal Cell is part of [Adobe Open Development Initiative](https://wiki.corp.adobe.com/display/opendev/Home), hence developed in an Adobe internal open-source manner. 
This being said, Metal Cell si more about integrating existing open-source projects and having them available as readily available services in our data centers. 

##Contact
Git: https://git.corp.adobe.com/metal-cell/metal-cell  
Users: DL-metal-cell-users <metal-cell-users@adobe.com>  
Developers: DL-MetaSky-Client-Dev <MetaSky-Client-Dev@adobe.com> (alias metal-cell@adobe.com)  
JIRA: 
Hipchat: https://adobemc.hipchat.com/rooms/show/618702/metalcell  

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
* Docker registry + HDFS support
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






Reference
========
* [The Datacenter as a Computer: An Introduction to the Design of Warehouse-Scale Machines](http://www.morganclaypool.com/doi/abs/10.2200/S00516ED2V01Y201306CAC024)  
* [Omega: flexible, scalable schedulers for large compute clusters](http://research.google.com/pubs/pub41684.html)
* [Mesos: A Platform for Fine-Grained Resource Sharing in the Data Center](https://www.cs.berkeley.edu/~alig/papers/mesos.pdf)

* [Platform Ecosystem Problem Statement](https://wiki.corp.adobe.com/display/omtrcache/The+Platform+Ecosystem)  
* [The future of the infrastructure is metal (cells) - Slides](https://www.dropbox.com/s/cw5a6bw9c7hhtvh/The%20Future%20of%20Platform%20is%20Metal%20%28cells%29.pptx)  
* [The future of the infrastructure is metal (cells) - Video Analytics Mini-Summit Recording](https://my.adobeconnect.com/p3wea44zvb0/) @~ 00:21:40  

