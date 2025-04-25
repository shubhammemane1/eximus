import 'package:eximus_user/models/pickup_request_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubit/porter_cubit.dart';

class AdminHome extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Requests'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<PorterCubit, PickUpState>(
          builder: (context, state) {
            if (state is PorterLoaded) {
              return StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('pickup_requests').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  }
                  final requests = snapshot.data!.docs.map((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    return PickUpRequestModel(
                      id: data['id'],
                      parcelDetails: data['parcelDetails'],
                      destinationCountry: data['destinationCountry'],
                      pickupArea: data['pickupArea'],
                      deliveryArea: data['deliveryArea'],
                      status: data['status'],
                    );
                  }).toList();

                  return ListView.builder(
                    itemCount: requests.length,
                    itemBuilder: (context, index) {
                      final request = requests[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 8.0),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(8.0),
                          title: Text(
                            request.parcelDetails,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Pickup: ${request.pickupArea}'),
                              Text('Delivery: ${request.deliveryArea}'),
                              Text('Status: ${request.status}'),
                            ],
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (status) async {
                              // Update request status in Firestore
                              await FirebaseFirestore.instance
                                  .collection('pickup_requests')
                                  .doc(request.id)
                                  .update({'status': status});
                              
                              // Update the status in the Cubit
                              context.read<PorterCubit>().updateStatus(request.id, status);
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(value: 'Accepted', child: Text('Accept')),
                              const PopupMenuItem(value: 'Rejected', child: Text('Reject')),
                              const PopupMenuItem(value: 'In Transit', child: Text('In Transit')),
                              const PopupMenuItem(value: 'Delivered', child: Text('Delivered')),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
