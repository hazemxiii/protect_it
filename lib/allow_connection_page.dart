// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:protect_it/server_page.dart';
// import 'package:protect_it/service/prefs.dart';

// class CommandPage extends StatefulWidget {
//   const CommandPage({super.key});

//   @override
//   State<CommandPage> createState() => _CommandPageState();
// }

// class _CommandPageState extends State<CommandPage> {
//   String command =
//       "New-NetFirewallRule -DisplayName \"Protect It\" -Direction Inbound -Action Allow -Protocol TCP -LocalPort 5000";
//   bool _dontShowAgain = false;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.white,
//       // appBar: AppBar(
//       //   backgroundColor: Colors.white,
//       //   foregroundColor: Colors.black,
//       //   centerTitle: true,
//       //   titleTextStyle:
//       //       const TextStyle(fontSize: 30, fontWeight: FontWeight.bold),
//       //   title: const Text("Server"),
//       // ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Container(
//               padding: const EdgeInsets.all(20),
//               margin: const EdgeInsets.all(20),
//               constraints: const BoxConstraints(maxWidth: 600),
//               decoration: BoxDecoration(
//                   border: Border.fromBorderSide(BorderSide(
//                       color: Color.lerp(Colors.white, Colors.black, 0.1)!)),
//                   borderRadius: const BorderRadius.all(Radius.circular(5))),
//               child: Column(
//                 children: [
//                   const Text(
//                     "Allow Connection",
//                     style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//                   ),
//                   Row(
//                     children: [
//                       Expanded(
//                         child: Text(
//                           overflow: TextOverflow.fade,
//                           "Open windows powershell as an admin and enter the following command",
//                           style: TextStyle(
//                               color:
//                                   Color.lerp(Colors.white, Colors.black, 0.5)),
//                         ),
//                       ),
//                       Tooltip(
//                         message:
//                             "To enable seamless file sharing, our app needs access to your device through a specific port. Adding an inbound rule allows our app to securely receive files from others. This is necessary for proper functionality and does not expose your system to unauthorized access. You can remove or modify this rule anytime in your firewall settings.",
//                         child: Container(
//                           decoration: const BoxDecoration(
//                               borderRadius:
//                                   BorderRadius.all(Radius.circular(999)),
//                               border: Border.fromBorderSide(
//                                   BorderSide(color: Colors.black))),
//                           child: const Icon(
//                             Icons.question_mark,
//                             size: 20,
//                           ),
//                         ),
//                       )
//                     ],
//                   ),
//                   _commandWidget(),
//                   CheckboxListTile(
//                       activeColor: Colors.black,
//                       title: const Text("Don't Show Again"),
//                       value: _dontShowAgain,
//                       onChanged: (v) {
//                         setState(() {
//                           _dontShowAgain = v!;
//                         });
//                       }),
//                   const SizedBox(
//                     height: 10,
//                   ),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [_btn(true), _btn(false)],
//                   )
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _commandWidget() {
//     return Container(
//       margin: const EdgeInsets.only(top: 10),
//       padding: const EdgeInsets.only(top: 5, bottom: 5, left: 15),
//       decoration: BoxDecoration(
//           color: Color.lerp(Colors.black, Colors.white, 0.9),
//           borderRadius: const BorderRadius.all(Radius.circular(5))),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Expanded(
//             child: SingleChildScrollView(
//                 scrollDirection: Axis.horizontal, child: Text(command)),
//           ),
//           IconButton(
//               iconSize: 15,
//               onPressed: _copy,
//               icon: const Icon(
//                 Icons.copy,
//               ))
//         ],
//       ),
//     );
//   }

//   Widget _btn(bool isCancel) {
//     return MaterialButton(
//       color: isCancel ? Colors.red : Colors.black,
//       padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 15),
//       shape: const RoundedRectangleBorder(
//           borderRadius: BorderRadius.all(Radius.circular(5))),
//       onPressed: isCancel ? Navigator.of(context).pop : _navigate,
//       child: Text(
//         isCancel ? "Cancel" : "OK",
//         style: const TextStyle(color: Colors.white),
//       ),
//     );
//   }

//   void _copy() async {
//     await Clipboard.setData(ClipboardData(text: command));
//     if (mounted) {
//       ScaffoldMessenger.of(context)
//           .showSnackBar(const SnackBar(content: Text("Copied")));
//     }
//   }

//   void _navigate() {
//     if (_dontShowAgain) {
//       Prefs.setDontShowAgain(true);
//     }
//     Navigator.of(context)
//         .pushReplacement(MaterialPageRoute(builder: (_) => const ServerPage()));
//   }
// }
