import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher_string.dart';
import '../../../constants.dart';

String contact = '0504930005';

void _callPhoneNumber() async {
  var url = 'tel://$contact';
  launchUrlString(url);
}

void _openWhatsappChat() async {
  var url = 'https://wa.me/$contact?text=I have a problem';
  launchUrlString(url);
}

HelpCenterDialog(BuildContext context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
          child: SizedBox(
              height: 350,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/close.svg',
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "Need help with application?",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(4.0),
                      child: Text(
                        "Contact us on the following .",
                        style: TextStyle(
                            fontSize: 15, fontWeight: FontWeight.normal),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    InkWell(
                      child: GestureDetector(
                        onTap: () {
                          _openWhatsappChat();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: kGreyColor700,
                            ),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Image.asset(
                                  'assets/images/chat-icon.png',
                                  width: 35,
                                  height: 35,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "WhatsApp us",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .copyWith()
                                          .scaffoldBackgroundColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                          ),
                        ),
                      ),
                    ),
                    InkWell(
                      child: GestureDetector(
                        onTap: () {
                          _callPhoneNumber();
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            height: 60,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8),
                              color: kGreyColor700,
                            ),
                            child: Center(
                                child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(
                                  Icons.call,
                                  size: 20,
                                ),
                                const SizedBox(
                                  width: 10,
                                ),
                                Text(
                                  "Call us on",
                                  style: TextStyle(
                                      color: Theme.of(context)
                                          .copyWith()
                                          .scaffoldBackgroundColor,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold),
                                ),
                              ],
                            )),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        );
      });
}

aboutUs(BuildContext context) {
  return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Dialog(
          shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(14))),
          child: SizedBox(
              height: 300,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: SvgPicture.asset(
                            'assets/icons/close.svg',
                            height: 40,
                            width: 40,
                          ),
                        ),
                      ],
                    ),
                    const Text(
                      "About TutorLink?",
                      style:
                          TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Center(
                        child: Image.asset(
                      'assets/images/Logop.png',
                      height: 80,
                      width: 80,
                    )),
                    const Icon(
                      Icons.help_outlined,
                      size: 40,
                      color: kGreyColor900,
                    ),
                    const Text(
                      'Version 1.0.1',
                      style: TextStyle(color: kBlackColor800),
                    )
                  ],
                ),
              )),
        );
      });
}
