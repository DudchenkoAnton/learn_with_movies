import 'package:basic_utils/basic_utils.dart';
import 'package:temp_project/services/networking.dart';
import 'package:temp_project/database/lesson_db.dart';

const String apiKey = 'AIzaSyC_VXT-0YR0J_EzlR19RaoKoaw0qXmVQ_o';
const requestMode = 'snippet,contentDetails';
const youtubeURL = 'https://www.googleapis.com/youtube/v3/videos?';

class YoutubeNetworkHelper {
  bool operationSuccessful = false;

  Future<bool> loadVideoData(LessonDB currentLesson) async {
    if (currentLesson.getVideoID() == null || currentLesson.getVideoID() == '') {
      return false;
    }
    var requestURL = '${youtubeURL}part=$requestMode&id=${currentLesson.getVideoID()}&key=$apiKey';
    NetworkHelper helper = NetworkHelper(requestURL);

    print('The request string:');
    print(requestURL);

    try {
      var response = await helper.getData();
      if (response != null && isNotLiveStream(response)) {
        updateVideoData(response, currentLesson);
        operationSuccessful = true;
      }
    } catch (e) {
      print('catched exception');
      operationSuccessful = false;
      print(e);
    }
    return operationSuccessful ? true : false;
  }

  bool isNotLiveStream(var response) {
    String liveStreamValue = response['items'][0]['snippet']['liveBroadcastContent'];
    if (liveStreamValue == 'none') {
      return true;
    } else {
      return false;
    }
  }

  void updateVideoData(dynamic response, LessonDB currentLesson) {
    int durationInSeconds;
    if (response != null) {
      String youtubeName = response['items'][0]['snippet']['title'];
      String youtubeDuration = response['items'][0]['contentDetails']['duration'];

      currentLesson.setYoutubeOriginalName(youtubeName);
      currentLesson.setVideoStartPoint(0);
      durationInSeconds = convertDuration(youtubeDuration);
      currentLesson.setVideoEndPoint(durationInSeconds);
      currentLesson.setOriginalVideoLength(durationInSeconds);
    }
  }

  int convertDuration(String youtubeFormatDuration) {
    int overallDuration = 0;
    int tempDuration = 0;

    if (youtubeFormatDuration.length <= 2) {
      // Todo: check how to throw exception in dart
      return 0;
    }

    for (int i = 2; i < youtubeFormatDuration.length; i++) {
      if (StringUtils.isDigit(youtubeFormatDuration[i])) {
        tempDuration = tempDuration * 10 + int.parse(youtubeFormatDuration[i]);
      } else if (youtubeFormatDuration[i] == 'H' ||
          youtubeFormatDuration[i] == 'M' ||
          youtubeFormatDuration[i] == 'S') {
        overallDuration = overallDuration * 60 + tempDuration;
        tempDuration = 0;
      } else {
        // Todo: check how to throw exception in dart
        return 0;
      }
    }
    return overallDuration;
  }
}
