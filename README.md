dart-jamp-examples
==================

Examples of using Dart and JAMP together. The backend class uses JAMP which is a open specification for implementing 
Actor based messaging and is part of Resin 7. JAMP protocol and the Java specification will be open and anyone can
implement it. There are some JAMP wire protocols specs. Essentially the JAMP wire protocol is just JSON over Websocket
or HTTP.

This is an early example of combining JAMP with Dart.

Using the annotations below this service is exposed via JAMP/Websockets to the Dart client.

```Java
package com.example;

import java.util.ArrayList;
import java.util.List;

import javax.annotation.PostConstruct;
import javax.ejb.Startup;

import com.caucho.amp.AmpPublish;
import com.caucho.amp.AmpService;

@AmpService
@AmpPublish("/test")
@Startup
public class EmployeeService {

	List<Employee> employees = new ArrayList<>();

	public boolean addEmployee(String firstName, String lastName) {
		employees.add(new Employee(firstName, lastName));
		return true;
	}

	public boolean removeEmployee(String firstName, String lastName) {
		employees.remove(new Employee(firstName, lastName));
		return true;
	}

	public List<Employee> list() {
		return employees;
	}

	@PostConstruct
	public void init() {
	}

}

```
RAMP (part of Resin 7) exposes that above service as a JAMP service.
RAMP gurantees that the abve service is accessed in a single thread using the actor model.

The Dart source which is part of this project whos how to formulate calls via JSON and recieve replies.
The Dart source implements a simple CRUD listing for employees.

You can learn more about JAMP here:

* http://hessian.caucho.com/jamp/index.xtp
* http://json-amp.github.com/
* https://github.com/json-amp/json-amp.github.com/wiki/Intro-to-JAMP
* http://hessian.caucho.com/jamp/draft-ferg-jamp-v0.html

The client sends JSON over websockets like this:

```
["query",{},"me",2,"/test","addEmployee","Rick","Hightower"]
```

The server sends back responses like this:

```
["reply",{},"me",1,true]
```


