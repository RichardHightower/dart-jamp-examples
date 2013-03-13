library jamp;
import 'dart:async';
import 'dart:html';
import 'dart:json' as json;
import 'mappable.dart';



WebSocket webSocket;
int messageId = 0;


class JampMethodCall {
  int queryId;
  String methodName;
  String serviceName;
  List<Object> args = [];
  Function func;
  JampMethodCall(int qid, String serviceName, String methodName, Function func) {
    this.queryId = qid;
    this.methodName = methodName;
    this.func = func;
    this.serviceName = serviceName;
  }
}

Map <String, JampMethodCall> calls = {};
Map <String, ReplyReciever> recievers = {};



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


void initWebSocket([int retrySeconds = 2]) {
  var encounteredError = false;


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
    print (list);
    if (list[0] == "reply") {
      replyRecieved(list[3], list[4]);
    }
  });
}


void replyRecieved (int qid, Object returnValue) {
  print ("replyRecieved");
  JampMethodCall call = calls["$qid"];
  ReplyReciever service = recievers[call.serviceName];
  service.replyRecieved(call, qid, returnValue);
  
}



abstract class ReplyReciever {
  void replyRecieved (JampMethodCall call, int qid, Object returnValue);
}






void invokeJampMethod(String serviceName, String methodName, Function callback, List<Mappable> args) {
  
  List list = [];
  list.add('"query"');
  list.add({});
  list.add('"me"');
  list.add(messageId);
  list.add(serviceName);
  list.add(methodName);
  for (Object obj in args) {
    if (obj is Mappable) {
      list.add(json.stringify(obj.toMap()));
    } else {
      list.add(json.stringify(obj));
    }
  }
  print (list);
  if (webSocket.readyState == WebSocket.OPEN) {
    webSocket.send(list.toString().replaceAll(" ", ""));
    JampMethodCall call = new JampMethodCall(messageId, serviceName, methodName, callback);
    calls["${messageId}"]=call;
    call.args.addAll(args);
  } else {
    print ("websocket  unable to send ${list.toString().replaceAll(" ", "")}");
  }
  messageId++;
}