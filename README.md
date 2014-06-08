Title:       Metal Cell  
Subtitle:    Adobe's Mechanically Sympathetic Datacenter as a Computer
Project:     Metal Cell  
Author:      Cosmin Lehene  
Affiliation: Adobe  
Web:         httt://metal.corp.adobe.com  
Date:        June 2, 2014  
Misc:        The current version of this document lives in my stackedit.io - keep that in mind if you want to make any changes  

Metal Cell
========
Metal Cell is Adobe's "Datacenter as a Computer" effort that attempts to move storage and computing from traditional, monolithic, multiple single-node setups to cluster and cluster-of-clusters.

"Exec Bullets"
--------------------------

* **Cost savings** through consolidated infrastructure and resource sharing
* **Improved time to market** through accelerated development and self service provisioning of both infrastructure (IaaS) and cluster level services (PaaS)

"Dev Bullets"
------------------

Any language at any layer between hardware and application on 

Abstract
-----------
The goal of Metal Cell is to improve Adobe products ***time to market*** and increase ***cost efficiency*** through shared, self-service infrastructure and cluster-level services.

The ***cell***  is the "new box". Applications or services that target a cell will, instead, access a much larger pool of resources (potentially spanning 10000s of nodes). 

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


Metal Cell 
========

Layers
---------

A good understanding of various layers and components of the Metal Cell is useful in order to understand  development practices.

Note that each layer could actually be viewed as a collection of layers as well.

###Infrastructure Level
The scope of the infrastructure-level software is limited to a node, so the firmware, drivers, kernel, operating system and clustering agents represent the software at this level. 

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

#### Coordination, Scheduling


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



Examples
-------------

**Edge collection**
Consider an event collection service with a HTTP API running on NGinx. The edge 


Developing the Cell
================

Metal Cell is part of [Adobe Open Development Initiative](https://wiki.corp.adobe.com/display/opendev/Home), hence developed in an Adobe internal open-source manner. 
This being said, Metal Cell si more about integrating existing open-source projects and having them available as readily available services in our data centers. 

There are several aspects of Metal Cell development:

HStack - Upstream OSS Projects Integration
Infrastructure - This deals with Adobe's infrastructure abstraction (e.g. CMDB integration)
Blueprint - Physical and Virtual nodes deployment of the core pieces of Metal Cell 



Architecture
==========

Related
======

History
======

Metal Cell got born out of learnings from years of running Hadoop, HBase, Zookeeper, Storm, Kafka and other in production. Planing new deployments - choosing hardware, automating deployments, doing performance and failover testing, over and over again. There's a new technology popping up every week at least and making choices is not always easy. Sometimes the best setup is on one technology sometimes on another and sometimes on both. However a proliferation of software stacks generally leads to a proliferation of hardware profiles and deployments and teams and it can lead to fragile infrastructure that further leads to fragile service to our customers. 



Reference
========
* [Platform Ecosystem Problem Statement](https://wiki.corp.adobe.com/display/omtrcache/The+Platform+Ecosystem)  
* [The future of the infrastructure is metal (cells) - Slides](https://www.dropbox.com/s/cw5a6bw9c7hhtvh/The%20Future%20of%20Platform%20is%20Metal%20%28cells%29.pptx)  
* [The future of the infrastructure is metal (cells) - Video Analytics Mini-Summit Recording](https://my.adobeconnect.com/p3wea44zvb0/) @~ 00:21:40  
* [The Datacenter as a Computer: An Introduction to the Design of Warehouse-Scale Machines](http://www.morganclaypool.com/doi/abs/10.2200/S00516ED2V01Y201306CAC024)  
