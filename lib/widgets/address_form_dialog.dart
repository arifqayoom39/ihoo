import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:ihoo/controllers/db_service.dart';
import 'package:ihoo/providers/user_provider.dart';

class AddressFormDialog extends StatefulWidget {
  const AddressFormDialog({super.key});

  @override
  State<AddressFormDialog> createState() => _AddressFormDialogState();
}

class _AddressFormDialogState extends State<AddressFormDialog> {
  final formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserProvider>(context, listen: false);
    _nameController.text = user.name;
    _emailController.text = user.email;
    _addressController.text = user.address;
    _phoneController.text = user.phone;
    setState(() => _isLoading = false);
  }

  InputDecoration _buildInputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: Colors.grey[600]),
      prefixIcon: Icon(icon, color: Colors.grey[600], size: 22),
      border: const OutlineInputBorder(),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(color: Colors.blue, width: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Update Delivery Details",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
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
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _phoneController,
                      decoration: _buildInputDecoration("Phone Number", Icons.phone_outlined),
                      validator: (value) => value!.isEmpty ? "Phone cannot be empty" : null,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _addressController,
                      decoration: _buildInputDecoration("Delivery Address", Icons.location_on_outlined),
                      validator: (value) => value!.isEmpty ? "Address cannot be empty" : null,
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 45,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : () async {
                          if (formKey.currentState!.validate()) {
                            setState(() => _isSaving = true);
                            var data = {
                              "name": _nameController.text,
                              "email": _emailController.text,
                              "address": _addressController.text,
                              "phone": _phoneController.text
                            };
                            await DbService().updateUserData(extraData: data);
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Delivery details updated successfully"),
                                backgroundColor: Colors.green,
                              )
                            );
                          }
                        },
                        child: _isSaving
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : const Text("SAVE CHANGES"),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
