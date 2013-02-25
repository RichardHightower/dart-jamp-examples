library components;

import 'dart:html';

const String nameRegexString = r"^[a-zA-ZàáâäãåèéêëìíîïòóôöõøùúûüÿýñçčšžÀÁÂÄÃÅÈÉÊËÌÍÎÏÒÓÔÖÕØÙÚÛÜŸÝÑßÇŒÆČŠŽ∂ð ,.'-]+$";
final RegExp nameRegex = new RegExp(nameRegexString);

/**
 *

This looks up locale string that are embedded in the HTML page in hidden span tags.
If you pass the key of "nameValidator" with a field of "First Name", this function will look for the following locale specific strings:
nameValidatorText-First-Name-en-US
nameValidatorText-en-US
nameValidatorText-en
nameValidatorText
<code>
    <div style="visibility:hidden">
      <div id="nameValidatorText">have letters and special charcters like ',.-</div>
      <div id="nameValidatorText-First-Name-en-US">{label} has illegal characters</div>
    </div>
</code>

The strings are stored in the HTML page itself in span tags of a hidden div.
If you do not specify a locale, the local is taken from window.navigator.language.
 */
String getLocaleString(String key, [String fieldName, String language, String country]) {
  String value;
  if (!?language) {
    String locale = window.navigator.language;
    List<String> list = locale.split("-");
    language = list[0];
    country = list[1];
  }
  if (?fieldName && fieldName!=null) {
    fieldName = fieldName.replaceAll("*", "").trim();
    value = getLocaleString("$key-${fieldName.replaceAll(' ', '-')}", null, language, country);
  }

  if (value=="undefined" || value == null){
    Element element = query("#${key}-${language}${country==null?'':'-$country'}");
    if (element == null) {
      element = query("#${key}-${language}");
    }
    if (element == null) {
      element = query("#${key}");
    }
    if (element == null) {
      value = "undefined";
    } else {
      value = element.text;
    }
  }

  return value != null ? value.replaceAll("{label}", fieldName == null ? "{label}" : fieldName) : "undefined";
}

bool nameValidator (String text, [LabelElement label, SpanElement element]) {
  if (text==null || text.isEmpty) {
    return false;
  }
  if (!nameRegex.hasMatch(text)) {

    if (?label){
      label.classes.add("error");
    }

    if (?element) {
      String nameValidatorText = getLocaleString("nameValidatorText", label.text);
      element.appendText(nameValidatorText);
      element.classes.add("error");
    }
    return false;
  }else {
    if (?label) {
      label.classes.remove("error");
    }
    if (?element) {
      element.classes.remove("error");
      element.text="";
    }
    return true;
  }
}

bool requiredValidator (String text, [LabelElement label, SpanElement element]) {
  if (text.isEmpty) {

    if (?label){
      label.classes.add("error");
    }

    if (?element) {
      String message = getLocaleString("requiredValidator", label.text);
      element.text = message;
      element.classes.add("error");
    }
    return false;
  }else {
    if (?label) {
      label.classes.remove("error");
    }
    if (?element) {
      element.classes.remove("error");
      element.text="";
    }
    return true;
  }
}


class TableComponent {
  Element _div;
  String rowTemplate;
  Element _rows;

  TableComponent(String tableName) {


    _div = query("#${tableName}Div");
    _rows = query("#${tableName}Rows");
    rowTemplate = _rows.innerHtml;


  }
  void setRows(String body) {
    _rows.innerHtml = body;
  }
  void turnOn() {
    _div.style.visibility="visible";
  }
}

class FieldComponent {
  String fieldName;
  TextInputElement textField;
  LabelElement label;
  SpanElement validationSpan;
  Function validator;
  Function requiredValidatorFunc = requiredValidator;
  Function action;

  FieldComponent (Element form, String fieldName, [Function action, Function validator]) {
    this.fieldName = fieldName;
    this.textField = form.query("#${fieldName}");
    assert(textField!=null);
    this.validationSpan = form.query("#${fieldName}Validation");
    this.label = form.query("#${fieldName}Label");
    if (?validator) {
      this.validator = validator;
    } else {
      this.validator = nameValidator;
    }
    /*
    textField.on.blur.add(_standardEventListener);
    */
    /*
    textField.on.focus.add(clearValidation);

    if (?action) {
      this.action = action;
      textField.on.keyUp.add(_keyUp);
    }

     */
  }

  void focus() {
    this.textField.focus();
  }

  void _keyUp(KeyboardEvent e) {
    if (e.keyCode==13) {
      action(e);
    }
  }
  void _standardEventListener(Event e) {

    this.validator(textField.value, this.label, this.validationSpan);
  }

  void clearValidation(Event e) {
      this.label.classes.remove("error");
      this.validationSpan.classes.remove("error");
      this.validationSpan.text="";
  }


  String value() {
    return textField.value;
  }

  String clear() {
    return textField.value="";
  }


  bool isValid() {
     if (requiredValidatorFunc!=null) {
      if (this.requiredValidatorFunc(textField.value, this.label, this.validationSpan)) {
        return this.validator(textField.value, this.label, this.validationSpan);
      } else {
        return false;
      }
    } else {
      return this.validator(textField.value, this.label, this.validationSpan);
    }
    return false;
  }
}
