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

import io.jamp.core.AmpPublish;

import java.util.ArrayList;
import java.util.List;

@AmpPublish("/empService")
public class EmployeeService {
	

	List<Employee> employees = new ArrayList<>();

	public boolean addEmployee(Employee employee) {
		employee.setId(generateId());
		employees.add(employee);
		return true;
	}

	public boolean removeEmployee(Employee employee) {
		employees.remove(employee);
		return true;
	}

	public List<Employee> list() {
		return employees;
	}

	
	private long generateId() {
		return System.currentTimeMillis();
	}

}
```
The Dart code to invoke the above would look like this:

```Java
library employeeService;
import 'employees.dart';
import 'jamp.dart' as jamp;

class EmployeeService implements jamp.ReplyReciever {

  List<Employee> employees = [];
  String name = '"/empService"';
  

  void addEmployee(Employee employee, Function callback) {
    print("addEmployee called Employee(${employee.firstName}, ${employee.lastName})" );
    jamp.invokeJampMethod(name, '"addEmployee"', callback, [employee]);
  }

  void removeEmployee(Employee employee, Function callback) {
    print("removeEmployee called Employee(${employee.firstName}, ${employee.lastName})" );
    
    jamp.invokeJampMethod(name, '"removeEmployee"', callback, [employee]);


  }

  void refreshList(Function callback) {
    
    jamp.invokeJampMethod(name, '"list"', callback, []);


  }
  ...

```
I also created a little sample security service 
(mainly so there would be two service so I could refactor the JAMP client lib 
or rather start to really create a JAMP client lib).


```Java
package com.example;

import java.util.HashMap;
import java.util.Map;

import io.jamp.core.AmpPublish;

import javax.ejb.Startup;

@AmpPublish("/securityService")
@Startup
public class SecurityService {
	private Map <String, User> users = new HashMap<>();
	
	{
		users.put("vipin", new User("vipin", "shock"));
		users.put("rick", new User("rick", "awe"));
		users.put("jeff", new User("jeff", "geoff"));
	}
	
	public boolean login(User aUser) {
		User user = users.get(aUser.getUserName());
		if (user == null) {
			return false;
		} else {
			return user.getPassword().equals(aUser.getPassword());
		}
	}
}

```
The Dart code to invoke the above service would look like this:
```Java
library login;
import 'dart:html';
import 'components.dart';
import 'jamp.dart' as jamp;


class LoginService implements jamp.ReplyReciever {
  String name = '"/securityService"';
  
  void login(String userName, String password, Function callback) {
    print("login called ${userName}, ${password})" );
    Map userMap = {"userName":userName, "password":password};
    jamp.invokeJampMethod(name, '"login"', callback, [userMap]);
  }
  
  void replyRecieved (jamp.JampMethodCall call, int qid, Object returnValue){
    
    if (call.methodName == '"login"') {
      bool loggedIn = returnValue as bool;
      jamp.calls.remove("$qid");
      call.func();
    } else {
      print("What? No log in??? Do some error handling TODO");
    }
  }

}
```
RAMP (part of Resin 7) exposes that above service as a JAMP service.
RAMP gurantees that the abve service is accessed in a single thread using the actor model.

The Dart source which is part of this project whos how to formulate calls via JSON and recieve replies.
The Dart source implements a simple CRUD listing for employees with a mock login service (which would have to be done differently).

You can learn more about JAMP here:

* http://hessian.caucho.com/jamp/index.xtp
* http://json-amp.github.com/
* https://github.com/json-amp/json-amp.github.com/wiki/Intro-to-JAMP
* http://hessian.caucho.com/jamp/draft-ferg-jamp-v0.html

The client sends JSON over websockets like this:

```
["query", {}, "me", 2, "/empService", "addEmployee", "Rick", "Hightower"]
```

The server sends back responses like this:

```
["reply", {}, "me", 2, true]
```


