 //this is to help the formatting the app
 String formatDuration(double duration) {
    int days = (duration / 24).floor();
    int hours = (duration % 24).floor();
    int minutes = ((duration - days * 24 - hours) * 60).round();

    String formattedDuration = '';
    if (days > 0) {
      formattedDuration += '$days d ';
    }
    if (hours > 0) {
      formattedDuration += '$hours h ';
    }
    if (minutes > 0) {
      formattedDuration += '$minutes m';
    }

    return formattedDuration.trim();
  }