library employees;
import 'mappable.dart';

class Employee implements Mappable {
  String firstName;
  String lastName;
  int id;
  
  Employee (String firstName, String lastName, int id) {
    this.firstName = firstName;
    this.lastName = lastName;
    this.id = id;
  }

  operator ==(Employee other) {
    return firstName == other.firstName && lastName == other.lastName;
  }

  int get hashCode {
    int result = 17;
    result = 37 * result + firstName.hashCode;
    result = 37 * result + lastName.hashCode;
    return result;
  }

  Map toMap() {
    return {"firstName" : this.firstName, "lastName" : this.lastName, "id" : this.id};
  }
}

