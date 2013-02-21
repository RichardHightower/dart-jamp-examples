library employees;

class Employee {
  String firstName;
  String lastName;
  Employee (String firstName, String lastName) {
    this.firstName = firstName;
    this.lastName = lastName;
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
    return {"firstName" : this.firstName, "lastName" : this.lastName};
  }
}

