import 'dart:math';


//Password generation
String generateRandomPassword() {
  final random = Random();//  get random characters
  final length = 8; // Minimum length of 8 characters
  const specialCharacters = "?=.*?[!@#\$&*;~%]";
  const uppercaseLetters = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
  const lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';

  final allowedCharacters =
      '$uppercaseLetters$lowercaseLetters${0123456789}$specialCharacters';
  String password = '';

  // Add 1 uppercase letter
  final uppercaseIndex = random.nextInt(uppercaseLetters.length);
  password += uppercaseLetters[uppercaseIndex];

  // Add 1 lowercase letter
  final lowercaseIndex = random.nextInt(lowercaseLetters.length);
  password += lowercaseLetters[lowercaseIndex];

  // Add 1 special character
  final specialCharIndex = random.nextInt(specialCharacters.length);
  password += specialCharacters[specialCharIndex];


  for (int i = password.length; i < length; i++) {
    final index = random.nextInt(allowedCharacters.length);
    password += allowedCharacters[index];
  }

 
  final passwordList = password.split('');
  passwordList.shuffle();
  password = passwordList.join('');

  return password;
}
