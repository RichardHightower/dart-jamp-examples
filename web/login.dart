library login;
import 'dart:html';
import 'components.dart';
import 'jamp.dart' as jamp;


DivElement loginDiv;
FieldComponent userName;
FieldComponent password;
ButtonElement loginButton;
DivElement showDiv;
LoginService loginService;
Function initApp;

void initLogin(DivElement aShowDiv, Function aInitApp) {
  showDiv = aShowDiv;
  initApp = aInitApp;
  Function loginAction = (Event e)=>loginUser();

  loginDiv = query("#loginPage");
  userName = new FieldComponent(loginDiv, "userName");
  password = new FieldComponent(loginDiv, "password");
  loginButton = query("#login");
  loginButton.onClick.listen(loginAction);

  loginService = new LoginService();
  jamp.recievers[loginService.name] = loginService;


}

void loginUser() {
  loginService.login(userName.value(), password.value(),loggedIn);
}

void loggedIn() {
  initApp();
  showDiv.style.visibility="visible";
  loginDiv.style.visibility="hidden";
}

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