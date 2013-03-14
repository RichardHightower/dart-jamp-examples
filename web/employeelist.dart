import 'dart:html';
import 'components.dart';
import 'employees.dart';
import 'employeeService.dart';
import 'login.dart' as login;
import 'jamp.dart' as jamp;



DivElement employeePage;
DivElement employeeForm;
FieldComponent firstName;
FieldComponent lastName;
ButtonElement addEmployeeButton;
ButtonElement refreshListButton;
Element message;

List<FieldComponent> components;

TableComponent table;

String rowTemplate = null;

void main() {
  employeePage = query("#employeePage");
  jamp.initWebSocket();

  login.initLogin(employeePage, initEmployeeListing);
}

void initEmployeeListing() {
  initEmployeeService();
  
  Function addAction = (Event e)=>addEmployee();
  Function refreshListAction = (Event e)=>refreshList();

  employeeForm = query("#employeeForm");
  firstName = new FieldComponent(employeeForm, "firstName", addAction);
  lastName = new FieldComponent(employeeForm, "lastName", addAction);
  addEmployeeButton = query("#addEmployee");
  refreshListButton = query("#refreshList");
  message = query("#message");

  addEmployeeButton.onClick.listen(addAction);
  refreshListButton.onClick.listen(refreshListAction);
  components = [firstName, lastName];
  table = new TableComponent("employee");
  refreshList();

}

void refreshList() {
  employeeService.refreshList(populateTable);

}

void addEmployee() {
  Employee employee = new Employee(firstName.value(), lastName.value(), 0);
  if (components.every(componentValid)) {
    employeeService.addEmployee(employee, populateTable);
    message.text = getLocaleString("employeeAdded");
  } else {
    message.text = getLocaleString("employeeFormNotValid");
    return;
  }
  components.forEach(clearTextField);
  firstName.focus();
}

void populateTable() {
  String rowTemplate = table.rowTemplate;
  StringBuffer body = new StringBuffer();
  int index = 0;
  for (Employee employee in employeeService.employees) {
    index++;
    body.write(rowTemplate
        .replaceAll("{{employee.firstName}}", employee.firstName)
        .replaceAll("{{employee.lastName}}", employee.lastName)
        .replaceAll("{{employee.id}}", employee.id.toString())
        .replaceAll("{{rowId}}", "$index"));
  }
  table.setRows(body.toString());
  List<Element> rowLinks = queryAll(".row-remove-link");
  rowLinks.forEach((Element e)=>e.onClick.listen(removeLinkClicked));
  table.turnOn();
}


void removeLinkClicked(MouseEvent event) {
  AnchorElement link = event.target;
  event.preventDefault();
  List<String> parts = link.href.split("/");
  String firstName = parts[3];
  String lastName = parts[4];
  int id = int.parse(parts[5]);
  Employee employee = new Employee(firstName, lastName, id);
  employeeService.removeEmployee(employee, populateTable);

}

bool clearTextField(FieldComponent comp) {
  comp.clear();
}
bool componentValid(FieldComponent comp) {
  return comp.isValid();
}