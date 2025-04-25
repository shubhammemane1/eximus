import 'package:eximus_user/screens/admin/admin_home_page.dart';
import 'package:eximus_user/screens/cubit/porter_cubit.dart';
import 'package:eximus_user/screens/user/user_home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RoleSelectionScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Role')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider(
                            create: (context) => PorterCubit(),
                            child: UserHome(),
                          ),
                    ),
                  ),
              child: const Text('User App'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => BlocProvider(
                            create: (context) => PorterCubit(),
                            child: AdminHome(),
                          ),
                    ),
                  ),
              child: const Text('Admin App'),
            ),
          ],
        ),
      ),
    );
  }
}
