import 'package:flutter/material.dart';
import '../constants.dart';

class Textform extends StatefulWidget {
  const Textform({
    super.key,
    required this.boxname,
    required this.preIcon,
    required this.keyboardtype,
    required this.validator,
    required this.controller,
  });
  //variables for the textforms
  final String boxname;
  final TextInputType keyboardtype;
  final Icon preIcon;
  final TextEditingController controller;
  final String? Function(dynamic value) validator;

  @override
  State<Textform> createState() => _TextformState();
}

// this whole wigdet tree is for a text form to be
//used for both the sign up and sign in pages

class _TextformState extends State<Textform> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.boxname,
          style: const TextStyle(
              color: kBlueColor, fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 20,
        ),
        //This is for the text form fill for signing up and signing in users
        TextFormField(
          keyboardType: widget.keyboardtype,
          controller: widget.controller,
          decoration: InputDecoration(
            prefixIcon: widget.preIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          validator: widget.validator,
        ),
      ]),
    );
  }
}

class PasswordForm extends StatefulWidget {
  const PasswordForm(
      {super.key,
      required this.boxname,
      required this.preIcon,
      required this.keyboardtype,
      required this.visiblePassword,
      required this.controller,
      required this.validator});

  final String boxname;
  final TextInputType keyboardtype;
  final Icon preIcon;
  final bool visiblePassword;
  final TextEditingController controller;
  final String? Function(dynamic value) validator;

  @override
  State<PasswordForm> createState() => _PasswordFormState();
}

class _PasswordFormState extends State<PasswordForm> {
  late bool _passwordVisible;
  @override
  void initState() {
    super.initState();
    _passwordVisible = widget.visiblePassword;
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.boxname,
            style: const TextStyle(
                color: kBlueColor, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(
            height: 20,
          ),
          TextFormField(
            obscureText: !_passwordVisible,
            keyboardType: widget.keyboardtype,
            controller: widget.controller,
            decoration: InputDecoration(
              prefixIcon: widget.preIcon,
              suffixIcon: IconButton(
                  onPressed: () {
                    setState(() {
                      _passwordVisible = !_passwordVisible;
                    });
                  },
                  icon: _passwordVisible
                      ? const Icon(Icons.visibility_outlined)
                      : const Icon(Icons.visibility_off_outlined)),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            validator: widget.validator,
          ),
        ],
      ),
    );
  }
}
