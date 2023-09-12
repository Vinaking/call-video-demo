import 'package:call_video_demo/models/meeting_details.dart';
import 'package:call_video_demo/pages/meeting_page.dart';
import 'package:flutter/material.dart';
import 'package:snippet_coder_utils/FormHelper.dart';

class JoinScreen extends StatefulWidget {
  final MeetingDetail? meetingDetail;

  const JoinScreen({Key? key, this.meetingDetail}) : super(key: key);

  @override
  State<JoinScreen> createState() => _JoinScreenState();
}

class _JoinScreenState extends State<JoinScreen> {
  static final GlobalKey<FormState> globalKey = GlobalKey<FormState>();
  String userName = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Join Meeting'),
        backgroundColor: Colors.redAccent,
      ),
      body: Form(key: globalKey, child: formUI()),
    );
  }

  formUI() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(
              height: 20,
            ),
            FormHelper.inputFieldWidget(
                context, "userId", "Enter Your Name", (val) {
              if (val.isEmpty) {
                return "Name can't be empty";
              }
              return null;
            }, (onSaved) {
              userName = onSaved;
            },
                borderRadius: 10,
                borderFocusColor: Colors.redAccent,
                borderColor: Colors.red,
                hintColor: Colors.grey),
            const SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Flexible(child: FormHelper.submitButton("Join Meeting", () {
                  if(validateAndSave()) {
                    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
                      return MeetingPage(
                        meetingId: widget.meetingDetail!.id,
                        name: userName,
                        meetingDetail: widget.meetingDetail!,
                      );
                    }));
                  }
                })),
              ],
            )
          ],
        ),
      ),
    );
  }

  bool validateAndSave() {
    final form = globalKey.currentState;
    if (form!.validate()) {
      form.save();
      return true;
    }

    return false;
  }
}
