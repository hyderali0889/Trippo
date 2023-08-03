class PredictedPlaces {
  String? placeId;
  String? mainText;
  String? secText;

  PredictedPlaces({this.placeId, this.mainText, this.secText});

  PredictedPlaces.fromJson(Map<String, dynamic> jsonData) {
    placeId = jsonData["place_id"];
    mainText = jsonData["structured_formatting"]["main_text"];
    secText = jsonData["structured_formatting"]["secondary_text"];
  }
}
