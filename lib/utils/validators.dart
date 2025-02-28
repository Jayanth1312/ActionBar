class Validators {
  static bool isValidEmail(String email) {
    final emailRegExp = RegExp(r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+');
    return emailRegExp.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    if (password.length < 8) {
      return false;
    }

    final hasNumber = RegExp(r'[0-9]').hasMatch(password);

    return hasNumber;
  }
}
