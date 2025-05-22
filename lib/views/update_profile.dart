import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/providers/user_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final Color flipkartBlue = const Color(0xFF2874F0);
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    user.loadUserData().then((_) {
      setState(() {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _addressController.text = user.address;
        _phoneController.text = user.phone;
        _isLoading = false;
      });
    });
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: flipkartBlue, width: 2),
      ),
      errorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red[300]!),
      ),
      focusedErrorBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: Colors.red[300]!, width: 2),
      ),
      errorStyle: TextStyle(color: Colors.red[300]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: flipkartBlue,
        elevation: 0,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w500),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: flipkartBlue))
          : SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(16),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Personal Information",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _nameController,
                            decoration: _buildInputDecoration("Full Name", Icons.person_outline),
                            validator: (value) => value!.isEmpty ? "Name cannot be empty" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _emailController,
                            readOnly: true,
                            decoration: _buildInputDecoration("Email", Icons.email_outlined),
                            validator: (value) => value!.isEmpty ? "Email cannot be empty" : null,
                          ),
                          const SizedBox(height: 16),
                          TextFormField(
                            controller: _phoneController,
                            decoration: _buildInputDecoration("Phone Number", Icons.phone_outlined),
                            validator: (value) => value!.isEmpty ? "Phone cannot be empty" : null,
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 30),
                          Text(
                            "Address Details",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                              color: Colors.grey[800],
                            ),
                          ),
                          const SizedBox(height: 20),
                          TextFormField(
                            controller: _addressController,
                            decoration: _buildInputDecoration("Delivery Address", Icons.location_on_outlined),
                            validator: (value) => value!.isEmpty ? "Address cannot be empty" : null,
                            maxLines: 3,
                          ),
                          const SizedBox(height: 30),
                          Container(
                            width: double.infinity,
                            height: 45,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : () async {
                                if (formKey.currentState!.validate()) {
                                  setState(() {
                                    _isSaving = true;
                                  });
                                  var data = {
                                    "name": _nameController.text,
                                    "email": _emailController.text,
                                    "address": _addressController.text,
                                    "phone": _phoneController.text
                                  };
                                  await DbService().updateUserData(extraData: data);
                                  setState(() {
                                    _isSaving = false;
                                  });
                                  Navigator.pop(context);
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text("Profile Updated Successfully"),
                                      backgroundColor: Colors.green,
                                    )
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: flipkartBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(2),
                                ),
                              ),
                              child: _isSaving
                                ? CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "SAVE CHANGES",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      letterSpacing: 1,
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
