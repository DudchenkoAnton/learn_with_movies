import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class YoutubeVideo extends StatefulWidget {
  final String videoID;
  final Duration startPoint;
  final Duration endPoint;

  YoutubeVideo({this.videoID, this.startPoint, this.endPoint});

  @override
  _YoutubeVideoState createState() => _YoutubeVideoState();
}

class _YoutubeVideoState extends State<YoutubeVideo> {
  YoutubePlayerController _controller;

  @override
  void initState() {
    _controller = YoutubePlayerController(
      initialVideoId: 'iLnmTe5Q2Qw',
      flags: YoutubePlayerFlags(
        mute: false,
        autoPlay: true,
        forceHideAnnotation: true,
      ),
    );
    _controller.seekTo(widget.startPoint);
    _controller.addListener(() {
      print(_controller.metadata);
      if (_controller.value.position < widget.startPoint) {
        _controller.seekTo(widget.startPoint);
        _controller.pause();
      } else if (_controller.value.position > widget.endPoint) {
        _controller.seekTo(widget.endPoint);
        _controller.pause();
      }
    });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      controller: _controller,
      showVideoProgressIndicator: true,
      onReady: () {
        print('Player is ready.');
        print(_controller.metadata);
      },
    );
  }
}
