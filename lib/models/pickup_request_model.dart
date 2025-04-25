class PickUpRequestModel {
  final String id;
  final String parcelDetails;
  final String destinationCountry;
  final String pickupArea;
  final String deliveryArea;
  final String status;

  PickUpRequestModel({
    required this.id,
    required this.parcelDetails,
    required this.destinationCountry,
    required this.pickupArea,
    required this.deliveryArea,
    required this.status,
  });

  PickUpRequestModel copyWith({String? status}) {
    return PickUpRequestModel(
      id: id,
      parcelDetails: parcelDetails,
      destinationCountry: destinationCountry,
      pickupArea: pickupArea,
      deliveryArea: deliveryArea,
      status: status ?? this.status,
    );
  }
}