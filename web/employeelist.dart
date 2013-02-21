import 'dart:html';
import 'components.dart';
import 'employees.dart';
import 'employeeService.dart';


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
  initEmployeeService();
  Function addAction = (Event e)=>addEmployee();
  Function refreshListAction = (Event e)=>refreshList();
  
  employeeForm = query("#employeeForm");
  firstName = new FieldComponent(employeeForm, "firstName", addAction);
  lastName = new FieldComponent(employeeForm, "lastName", addAction);
  addEmployeeButton = query("#addEmployee");
  refreshListButton = query("#refreshList");
  message = query("#message");
  
  addEmployeeButton.on.click.add(addAction);
  
  
  /*
  refreshListButton.on.click.add(refreshListAction);
  */
  components = [firstName, lastName];
  table = new TableComponent("employee");
}

void refreshList() {
  employeeService.refreshList(populateTable);

}

void addEmployee() {
  Employee employee = new Employee(firstName.value(), lastName.value());
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
    body.add(rowTemplate
        .replaceAll("{{employee.firstName}}", employee.firstName)
        .replaceAll("{{employee.lastName}}", employee.lastName)
        .replaceAll("{{rowId}}", "$index"));
  }    
  table.setRows(body.toString());
  List<Element> rowLinks = queryAll(".row-remove-link");
  rowLinks.forEach((Element e)=>e.on.click.add(removeLinkClicked));
  table.turnOn();  
}


void removeLinkClicked(MouseEvent event) {
  AnchorElement link = event.target;
  event.preventDefault();
  List<String> parts = link.href.split("/");
  String firstName = parts[3];
  String lastName = parts[4];
  Employee employee = new Employee(firstName, lastName);
  employeeService.removeEmployee(employee, populateTable);
  
}

bool clearTextField(FieldComponent comp) {
  comp.clear();
}
bool componentValid(FieldComponent comp) {
  return comp.isValid();
}