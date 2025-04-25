import 'package:eximus_user/models/pickup_request_model.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../cubit/porter_cubit.dart';

class UserHome extends StatefulWidget {
  @override
  State<UserHome> createState() => _UserHomeState();
}

class _UserHomeState extends State<UserHome> {
  final parcelController = TextEditingController();

  final countryController = TextEditingController();

  final pickupController = TextEditingController();

  final deliveryController = TextEditingController();

    FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;

  @override
  void initState() {
    super.initState();
    // Request permission for iOS
    _requestNotificationPermissions();

    // Get the token
    _getDeviceToken();

    // Listen to foreground messages
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('Message received: ${message.notification?.title}');
      // Show a local notification or update the UI
    });

    // Handle when app is in background or terminated
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('Message clicked: ${message.notification?.title}');
      // Navigate to specific screen or update the UI
    });
  }




  // Request notification permissions (iOS)
  void _requestNotificationPermissions() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission();
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission for notifications');
    } else {
      print('User denied permission for notifications');
    }
  }

  // Get the Firebase token for this device
  void _getDeviceToken() async {
    String? token = await _firebaseMessaging.getToken();
    print('Device token: $token');
    // You can send this token to your backend for sending targeted notifications
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('User - New Request')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: parcelController, decoration: const InputDecoration(labelText: 'Parcel Details')),
            TextField(controller: countryController, decoration: const InputDecoration(labelText: 'Destination Country')),
            TextField(controller: pickupController, decoration: const InputDecoration(labelText: 'Pickup City/Area')),
            TextField(controller: deliveryController, decoration: const InputDecoration(labelText: 'Delivery City/Area')),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                context.read<PorterCubit>().createRequest(
                      parcelController.text,
                      countryController.text,
                      pickupController.text,
                      deliveryController.text,
                    );
              },
              child: const Text('Create Request'),
            ),
            const SizedBox(height: 20),
            Expanded(
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
                            final r = requests[index];
                            return ListTile(
                              title: Text(r.parcelDetails),
                              subtitle: Text('Status: ${r.status}\nPickup: ${r.pickupArea}\nDelivery: ${r.deliveryArea}'),
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
          ],
        ),
      ),
    );
  }
}
