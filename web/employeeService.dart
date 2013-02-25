library employeeService;
import 'employees.dart';
import 'dart:html';
import 'dart:async';
import 'dart:json' as json;


EmployeeService employeeService;

class JampMethodCall {
  int queryId;
  String methodName;
  List<Object> args = [];
  Function func;
  JampMethodCall(int qid, String methodName, Function func) {
    this.queryId = qid;
    this.methodName = methodName;
    this.func = func;
  }
}

Map <String, JampMethodCall> calls = {};


String buildWebSocketURL(String uri) {
  String url = window.location.href;
  List<String> parts = url.split('/');
  String scheme = parts[0];
  String hostPort = parts[2];
  String wssScheme = null;


  if (scheme=="http:") {
    wssScheme="ws:";
  } else if (scheme=="https:") {
    wssScheme="wss:";
  }

  hostPort = hostPort.replaceAll("3030", "8080");

  String wssUrl = "${wssScheme}//${hostPort}${uri}";

  return wssUrl;

}


WebSocket initWebSocket([int retrySeconds = 2]) {
  var encounteredError = false;
  WebSocket webSocket;


  String url = buildWebSocketURL("/employeeService/jamp");
  print ("URL = $url");
  webSocket = new WebSocket(url);

  webSocket.onOpen.listen((e) {
    print('Connected');
  });

  webSocket.onClose.listen((e) {
    print('web socket closed, retrying in $retrySeconds seconds');
    if (!encounteredError) {
      new Timer(1000*retrySeconds, (t) => initWebSocket(retrySeconds*2));
    }
    encounteredError = true;
  });

  webSocket.onError.listen((e) {
    print("Error connecting to ws");
    if (!encounteredError) {
      new Timer(1000*retrySeconds, (t) => initWebSocket(retrySeconds*2));
    }
    encounteredError = true;
  });
  
  

  webSocket.onMessage.listen((MessageEvent e) {
    print('received message ${e.data}');
    String data = (e.data as String).replaceAll(":,", ":");
    List list = json.parse(data) as List;
    if (list[0] == "reply") {
      employeeService.replyRecieved(list[3], list[4]);
    }
  });


  return webSocket;
}


class EmployeeService {

  WebSocket webSocket;
  int messageId = 1;
  List<Employee> employees = [];



  EmployeeService() {
    this.webSocket = initWebSocket();
  }

  void replyRecieved (int qid, Object returnValue) {
    print ("replyRecieved");
    JampMethodCall call = calls["$qid"];
    if (call.methodName == "addEmployee") {
      bool added = returnValue as bool;
      if (added) {
        employees.add(call.args[0]);
      }
      calls.remove("$qid");
      call.func();
    } else if (call.methodName == "removeEmployee") {
      bool removed = returnValue as bool;
      if (removed) {
        doRemoveEmployee(call.args[0]);
      }
      calls.remove("$qid");
      call.func();
    } else if (call.methodName == "list") {
      employees = [];
      List<Map> maps = returnValue as List<Map>;
      for (Map map in maps) {
        Employee e = new Employee(map["firstName"], map["lastName"]);
        employees.add(e);
      }
      calls.remove("$qid");
      call.func();
    }
  }
  void addEmployee(Employee employee, Function func) {
    print("addEmployee called Employee(${employee.firstName}, ${employee.lastName})" );
    List list = [];
    list.add('"query"');
    list.add({});
    list.add('"me"');
    list.add(messageId);
    list.add('"/test"');
    list.add('"addEmployee"');
    list.add('"${employee.firstName}"');
    list.add('"${employee.lastName}"');
    //list.add(json.stringify(employee.toMap()));
    //print(list.toString());
    if (this.webSocket.readyState == WebSocket.OPEN) {
      this.webSocket.send(list.toString().replaceAll(" ", ""));
      JampMethodCall call = new JampMethodCall(messageId, "addEmployee", func);
      calls["${messageId}"]=call;
      call.args.add(employee);
    } else {
      print ("websocket  unable to send ${list.toString().replaceAll(" ", "")}");
    }
    messageId++;
  }

  void removeEmployee(Employee employee, Function func) {
    print("removeEmployee called Employee(${employee.firstName}, ${employee.lastName})" );
    List list = [];
    list.add('"query"');
    list.add({});
    list.add('"me"');
    list.add(messageId);
    list.add('"/test"');
    list.add('"removeEmployee"');
    list.add('"${employee.firstName}"');
    list.add('"${employee.lastName}"');
    print(list.toString());
    if (this.webSocket.readyState == WebSocket.OPEN) {
      this.webSocket.send(list.toString().replaceAll(" ", ""));
      JampMethodCall call = new JampMethodCall(messageId, "removeEmployee", func);
      calls["${messageId}"]=call;
      call.args.add(employee);
    } else {
      print ("websocket  unable to send ${list.toString().replaceAll(" ", "")}");
    }
    messageId++;

  }

  void refreshList(Function func) {
    print("refresh list called ");
    List list = [];
    list.add('"query"');
    list.add({});
    list.add('"me"');
    list.add(messageId);
    list.add('"/test"');
    list.add('"list"');
    print(list.toString());
    if (this.webSocket.readyState == WebSocket.OPEN) {
      this.webSocket.send(list.toString().replaceAll(" ", ""));
      JampMethodCall call = new JampMethodCall(messageId, "list", func);
      calls["${messageId}"]=call;
    } else {
      print ("websocket  unable to send ${list.toString().replaceAll(" ", "")}");
    }
    messageId++;

  }


  void doRemoveEmployee(Employee employee) {
    int index = employeeService.employees.indexOf(employee);
    if (index!=-1) {
      employeeService.employees.removeAt(index);
    }

  }


}

void initEmployeeService(){

  employeeService = new EmployeeService();
}

