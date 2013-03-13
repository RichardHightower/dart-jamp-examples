library employeeService;
import 'employees.dart';
import 'jamp.dart' as jamp;



EmployeeService employeeService;



class EmployeeService implements jamp.ReplyReciever {

  List<Employee> employees = [];
  String name = '"/empService"';
  
  void replyRecieved (jamp.JampMethodCall call, int qid, Object returnValue){
    
    if (call.methodName == '"addEmployee"') {
      bool added = returnValue as bool;
      if (added) {
        employees.add(call.args[0]);
      }
      jamp.calls.remove("$qid");
      call.func();
    } else if (call.methodName == '"removeEmployee"') {
      bool removed = returnValue as bool;
      if (removed) {
        doRemoveEmployee(call.args[0]);
      }
      jamp.calls.remove("$qid");
      call.func();
    } else if (call.methodName == '"list"') {
      employees = [];
      List<Map> maps = returnValue as List<Map>;
      for (Map map in maps) {
        Employee e = new Employee(map["firstName"], map["lastName"]);
        employees.add(e);
      }
      jamp.calls.remove("$qid");
      call.func();
    }

  }

  void addEmployee(Employee employee, Function callback) {
    print("addEmployee called Employee(${employee.firstName}, ${employee.lastName})" );
    jamp.invokeJampMethod(name, '"addEmployee"', callback, [employee]);
  }

  void removeEmployee(Employee employee, Function callback) {
    print("removeEmployee called Employee(${employee.firstName}, ${employee.lastName})" );
    
    jamp.invokeJampMethod(name, '"removeEmployee"', callback, [employee]);


  }

  void refreshList(Function callback) {
    
    jamp.invokeJampMethod(name, '"refreshList"', callback, []);


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
  jamp.recievers[employeeService.name] = employeeService;
}

