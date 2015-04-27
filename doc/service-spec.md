# Intro
A **service** (also called "micro-service") is an abstraction for a *functionality* provided through an *interface* to  it's *consumers*.

The goal of this spec is to capture the fundamental aspects of a service into a simple declarative fashion and be agnostic to particular implementations of containers, service schedulers or resource managers, etc. (e.g. Marathon, Kubernetes, Docker, Rocket, etc.).

A service has  service *definition*/*template* and a service *instance*.

The service *instance* 

A *job* is an instance of a service managed by a *job scheduler* and a *resource manager* in a *cell* and consists of multiple container instances (see Metal Cell Hierarchy for more).

The service instantiation can have one ore more *jobs* depending if the service can span across cells.
VS. (MERGE)
Multiple jobs can run in separate cells, potentially across geographical reasons and still be part of the same (geographically distributed) service.

E.g.
A human readable example of the above statement is  
*"A service may be represented by a Marathon (scheduler) application (job) running on Mesos (resource manager) within a cluster (~cell)."*



# The spec

## Service lifecycle

### Development
A service is *defined* during implementation as part of the ***development-phase***.
A service *definition* is version controlled and branched with the service *implementation* (code) and follows the typical software development life cycle.

### Build / Release
During the ***build-phase***  the service *definition* will have *some* of it's container-level free variables bound (e.g. to a *specific version* or *container image* that resulted out of the build process which is accessible through a URL for example). TBD


### Deployment
In the ***deploy-phase*** the service will get fully materialized/reified (APPC: resolved)
The job will have the rest of the free variables, along with those of it's *dependencies* as *attached resources* (per 12factor) bound (e.g. to a specific cell environment and the corresponding depending service instances within that cell) and may be *transformed* in an environment specific workload definition (e.g. a Marathon or a Kubernetes service definition).

### Runtime
Mutable vs Immutable Services TBD
A service can be *transformed* at runtime by having its *job* scaled through the scheduler or have it's job's container images updated, etc.	


## Service **Definition**

The **service definition** is a *declarative* representation of a service (REPHRASE). The **service instance** (or just service) represents a running workload (instantiation).

### General service information
Service **Name** - identifies the service. You can think of it as a type name.

```
name: chronos
dependencies: [mesos, zookeeper]
```

### Service **Endpoints**
The service endpoints list represents the service's interface to it's consumers. 
An endpoint has a name, a protocol, a port, a version and a URL that clients can use to consume it.

amuraru: what about it's API's documenation?

```
endpoints: 
 - name: default
   protocol: http
   port: 8081
   version: 1
   url: http//example.com/gateway
```


### Service **Jobs** (Job Templates?)
A single *instance* of a service can span multiple cells represented as a **job** in each cell.

amuraru: add a diagram?

A **job** has a `name` / `id` that uniquely identifies it in a cell.
```
jobs:
  job:
    id: nginx/gateway
    description: the nginx gateway
```

### Job/**Container**
Each *Job* has a specific container image.
A service can have multiple jobs with different container images.

The service **Container** is the *binary representation* of the service in it's *executable* form. It specifies the container image *coordinates* (such as an image URI containing the location image identifier and version) along with the container level resources. 

```
  container:
    image: mesos/mesos
	resources:
	  cpus: 1
```

### Service Job-level configuration (RENAME)
A service job will get deployed to one cell. The cell `name`  will be used to identify the target cell.
Cell-level resources can be specified here.
```
 cell:
	# to be closed at deploy-time
    name: {{ cell.name }}  
    resources:
	  instances: 3
```
### Example
```
# chronos service template example

# service name
name: chronos
# service level dependencies - any open variables would need to be closed 
# in their corresponding phases
dependencies: [mesos, zookeeper]
# protocol used to expose functionality
endpoints: 
 - name: default
   protocol: http
   port: 8081
   version: 1

job:
  id: {{ job.id | default("/metalcell/chronos-1") }}
  description: {{ job.description | default("Chronos cluster scheduler") }}
  # defines the container job-related requirements
  # not specifying a full container like libcontainer or app container
  container:
  # to be closed at build-time
  # TODO replace with container reference 
    image: {{ container.image }}
  resources:
    cpus: 1
    memory: 128
    network: 
  	  in: 0
  	  out: 0
  cell:
  # to be closed at deploy-time
    name: {{ cell.name }}  
    resources:
    instances: 3
  env:
    key: value # TODO determine if key is fully qualified
	  

# this should live outside of the service
scheduler: marathon #kubernetes, aurora, etc.
```


# References

[kubernetes/services](https://github.com/GoogleCloudPlatform/kubernetes/blob/master/docs/services.md)
[marathon/application groups](http://mesosphere.github.io/marathon/docs/application-groups.html)
[docker/compose](https://docs.docker.com/compose/)
[12factor.net/backing-services](http://12factor.net/backing-services)
[libcontainer spec](https://github.com/docker/libcontainer/blob/master/SPEC.md)
[App Container spec](https://github.com/appc/spec/blob/master/SPEC.md)
[Mesos Architecture](http://mesos.apache.org/documentation/latest/mesos-architecture/)




