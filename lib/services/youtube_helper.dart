import 'package:temp_project/utilites/lesson_objects.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:temp_project/services/networking.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'dart:convert' as convert;

const String apiKey = 'AIzaSyC1A409ejzuIRRJgeSLdwrw7slhUR4xL-k';
const requestMode = 'snippet,contentDetails';
const youtubeURL = 'https://www.googleapis.com/youtube/v3/videos?';

class YoutubeNetworkHelper {
  Future<bool> loadVideoData(LessonData currentLesson) async {
    if (currentLesson.videoId == null || currentLesson.videoId == '') {
      return false;
    }
    var requestURL =
        '${youtubeURL}part=$requestMode&id=${currentLesson.videoId}&key=$apiKey';
    NetworkHelper helper = NetworkHelper(requestURL);

    print('The request string:');
    print(requestURL);

    var response = await helper.getData();
    if (response != null) {
      updateVideoData(response, currentLesson);
      return true;
    }
    return false;
  }

  void updateVideoData(dynamic response, LessonData currentLesson) {
    if (response != null) {
      String youtubeName = response['items'][0]['snippet']['title'];
      String youtubeDuration =
          response['items'][0]['contentDetails']['duration'];

      currentLesson.youtubeName = youtubeName;
      currentLesson.start = Duration(seconds: 0);
      currentLesson.end = Duration(seconds: 120);

      print(youtubeName);
      print(youtubeDuration);
      print(currentLesson.end);
    }
  }

  int convertDuration(String youtubeFormatDuration) {
    print(youtubeFormatDuration);

    String tempNum = '';
    bool numMode = false;
    int stringLen = youtubeFormatDuration.length;
    int durationInSeconds = 0;

    for (int i = 0; i < stringLen; i++) {
      if (StringUtils.isDigit(youtubeFormatDuration[i])) {
        numMode = true;
        tempNum += youtubeFormatDuration[i];
      } else if (numMode = true) {
        numMode = false;
        print(tempNum);
        int parsedNum = int.parse(tempNum);
        tempNum = '';
        int multiplier = 0;
        if (youtubeFormatDuration[i] == 's') {
          multiplier = 1;
        } else if (youtubeFormatDuration[i] == 'm') {
          multiplier = 60;
        }

        durationInSeconds += parsedNum * multiplier;
      }
    }

    return durationInSeconds;
  }
}
