import 'package:call_video_demo/models/meeting_details.dart';
import 'package:call_video_demo/pages/home_screen.dart';
import 'package:call_video_demo/utils/user.utils.dart';
import 'package:call_video_demo/widgets/control_panel.dart';
import 'package:call_video_demo/widgets/remote_connection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';
import 'package:flutter_webrtc_wrapper/flutter_webrtc_wrapper.dart';

class MeetingPage extends StatefulWidget {
  final String? meetingId;
  final String? name;
  final MeetingDetail meetingDetail;
  const MeetingPage(
      {Key? key, this.meetingId, this.name, required this.meetingDetail})
      : super(key: key);

  @override
  State<MeetingPage> createState() => _MeetingPageState();
}

class _MeetingPageState extends State<MeetingPage> {
  final _localRenderer = RTCVideoRenderer();
  final Map<String, dynamic> mediaConstraints = {"audio": true, "video": true};
  bool isConnectionFailed = false;
  WebRTCMeetingHelper? meetingHelper;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black87,
      body: _buildMeetingRoom(),
      bottomNavigationBar: ControlPanel(
        onAudioToggle: onAudioToggle,
        onVideoToggle: onVideoToggle,
        videoEnabled: isVideoEnabled(),
        audioEnabled: isAudioEnabled(),
        isConnectionFailed: isConnectionFailed,
        onReconnect: handleReconnect,
        onMeetingEnd: onMeetingEnd,
      ),
    );
  }

  void startMeeting() async {
    final String userId = await loadUserId();
    MediaStream _localStream =
    await navigator.mediaDevices.getUserMedia(mediaConstraints);

    meetingHelper = WebRTCMeetingHelper(
      // url: "https://call-video-server.onrender.com",
      url: "https://call-video-server.onrender.com",
      meetingId: widget.meetingDetail.id,
      userId: userId,
      name: widget.name,
    );

    _localRenderer.srcObject = _localStream;
    meetingHelper!.stream = _localStream;

    meetingHelper!.on("open", context, (ev, context) {
      print("socketio: one");
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("connection", context, (ev, context) {
      print("socketio: connection");
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("user-left", context, (ev, context) {
      print("socketio: user-left");
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("video-toggle", context, (ev, context) {
      print("socketio: video-toggle");
      setState(() {});
    });
    meetingHelper!.on("audio-toggle", context, (ev, context) {
      print("socketio: audio-toggle");
      setState(() {});
    });
    meetingHelper!.on("meeting-ended", context, (ev, context) {
      print("socketio: meeting-ended");
      setState(() {
        onMeetingEnd();
      });
    });
    meetingHelper!.on("connection-setting-changed", context, (ev, context) {
      print("socketio: connection-setting-changed");
      setState(() {
        isConnectionFailed = false;
      });
    });
    meetingHelper!.on("stream-changed", context, (ev, context) {
      print("socketio: stream-changed");
      setState(() {
        isConnectionFailed = false;
      });
    });

    setState(() {});
  }

  initRenderer() async {
    await _localRenderer.initialize();
  }

  @override
  void initState() {
    super.initState();
    initRenderer();
    startMeeting();
  }

  @override
  void deactivate() {
    super.deactivate();
    _localRenderer.dispose();
    if (meetingHelper != null) {
      meetingHelper!.destroy();
      meetingHelper = null;
    }
  }

  void onMeetingEnd() {
    if (meetingHelper != null) {
      meetingHelper!.leave();
      meetingHelper = null;
      goToHomePage();
    }
  }

  _buildMeetingRoom() {
    return Stack(
      children: [
        meetingHelper != null && meetingHelper!.connections.isNotEmpty
            ? GridView.count(
          crossAxisCount: meetingHelper!.connections.length < 2 ? 1 : 2,
          children:
          List.generate(meetingHelper!.connections.length, (index) {
            return Padding(
              padding: const EdgeInsets.all(1),
              child: RemoteConnection(
                renderer: meetingHelper!.connections[index].renderer,
                connection: meetingHelper!.connections[index],
              ),
            );
          }),
        )
            : const Center(
          child: Padding(
            padding: EdgeInsets.all(10),
            child: Text(
              "Waiting for participants to join the meeting",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey, fontSize: 24),
            ),
          ),
        ),
        Positioned(
          bottom: 10,
          right: 0,
          child: SizedBox(
            width: 150,
            height: 200,
            child: RTCVideoView(_localRenderer),
          ),
        )
      ],
    );
  }

  void onAudioToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleAudio();
      });
    }
  }

  void onVideoToggle() {
    if (meetingHelper != null) {
      setState(() {
        meetingHelper!.toggleVideo();
      });
    }
  }

  void handleReconnect() {
    if (meetingHelper != null) {
      meetingHelper!.reconnect();
    }
  }

  bool isAudioEnabled() {
    return meetingHelper != null ? meetingHelper!.audioEnabled! : false;
  }

  isVideoEnabled() {
    return meetingHelper != null ? meetingHelper!.videoEnabled! : false;
  }

  void goToHomePage() {
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => const HomeScreen()));
  }
}
