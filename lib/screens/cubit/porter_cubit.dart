import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:eximus_user/models/pickup_request_model.dart';
import 'package:meta/meta.dart';

part 'porter_state.dart';

class PorterCubit extends Cubit<PorterState> {
  PorterCubit() : super(PorterLoaded([]));

  void createRequest(
    String parcelDetails,
    String destinationCountry,
    String pickupArea,
    String deliveryArea,
  ) async {
    if (state is PorterLoaded) {
      final current = (state as PorterLoaded).requests;

      // Create a new request model
      final newRequest = PickUpRequestModel(
        id: "", // Generate a new ID when you add it to Firestore
        parcelDetails: parcelDetails,
        destinationCountry: destinationCountry,
        pickupArea: pickupArea,
        deliveryArea: deliveryArea,
        status: 'Pending',
      );

      // Add request to Firestore
      final docRef =
          FirebaseFirestore.instance
              .collection('pickup_requests')
              .doc(); // This creates a new document with auto ID
      await docRef.set({
        'id': docRef.id, // Use Firestore auto-generated doc ID
        'parcelDetails': parcelDetails,
        'destinationCountry': destinationCountry,
        'pickupArea': pickupArea,
        'deliveryArea': deliveryArea,
        'status': 'Pending', // Ensure the status is also added
      });

      // Now emit the new state with updated requests list
      emit(PorterLoaded([...current, newRequest]));
    }
  }

  void updateStatus(String id, String status) async {
    if (state is PorterLoaded) {
      final currentRequests = (state as PorterLoaded).requests;
      final updatedRequests = currentRequests.map((r) {
        return r.id == id ? r.copyWith(status: status) : r;
      }).toList();

      // Emit updated state to notify listeners
      emit(PorterLoaded(updatedRequests));

      // Also update Firestore with the new status
      await FirebaseFirestore.instance.collection('pickup_requests').doc(id).update({
        'status': status,
      });
    }
  }
}
