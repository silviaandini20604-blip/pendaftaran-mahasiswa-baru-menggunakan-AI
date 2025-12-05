import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';

class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  // Fungsi buat handle login
  void _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final apiService = Provider.of<ApiService>(context, listen: false);

        debugPrint("=== LOGIN DEBUG START ===");
        debugPrint("👉 Username: ${_usernameController.text}");
        debugPrint("👉 Password: ${_passwordController.text}");

        // TEST: panggil API
        final response = await apiService.login(
          _usernameController.text,
          _passwordController.text,
        );

        debugPrint("📡 RESPONSE DARI BACKEND:");
        debugPrint(response.toString());
        debugPrint("=== LOGIN DEBUG END ===");

        // Jika berhasil
        if (response['message'] == 'Login successful') {
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(response['error'] ?? "Login gagal")),
          );
        }
      } catch (e) {
        debugPrint("❌ ERROR LOGIN:");
        debugPrint(e.toString());

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Login failed: $e')));
      } finally {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Container(
            height: MediaQuery.of(context).size.height,
            padding: EdgeInsets.all(24.0),
            child: Column(
              children: [
                // Header Section
                _buildHeaderSection(),

                // Form Section
                _buildFormSection(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget buat header yang ada logo dan welcome message
  Widget _buildHeaderSection() {
    return Expanded(
      flex: 2,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Logo dengan gradient yang estetik
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: Icon(Icons.work_outline, color: Colors.white, size: 40),
          ),
          SizedBox(height: 24),
          Text(
            'Welcome Back',
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Silahkan login untuk memulai tes',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Widget buat section form login
  Widget _buildFormSection() {
    return Expanded(
      flex: 3,
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Username Field
            _buildUsernameField(),
            SizedBox(height: 16),

            // Password Field
            _buildPasswordField(),
            SizedBox(height: 8),

            // Forgot Password
            _buildForgotPassword(),
            SizedBox(height: 24),

            // Login Button
            _buildLoginButton(),
            SizedBox(height: 24),

            // NOTE: Section register dan divider dikomen, mungkin buat fitur selanjutnya
            // // Divider
            // Row(
            //   children: [
            //     Expanded(child: Divider(color: Colors.grey[300])),
            //     Padding(
            //       padding: EdgeInsets.symmetric(horizontal: 16),
            //       child: Text(
            //         'or',
            //         style: TextStyle(color: Colors.grey[500]),
            //       ),
            //     ),
            //     Expanded(child: Divider(color: Colors.grey[300])),
            //   ],
            // ),
            // SizedBox(height: 24),

            // // Register Button
            // TextButton(
            //   onPressed: () {
            //     Navigator.pushNamed(context, '/register');
            //   },
            //   child: RichText(
            //     text: TextSpan(
            //       text: "Don't have an account? ",
            //       style: TextStyle(color: Colors.grey[600]),
            //       children: [
            //         TextSpan(
            //           text: 'Register',
            //           style: TextStyle(
            //             color: Color(0xFF667EEA),
            //             fontWeight: FontWeight.w600,
            //           ),
            //         ),
            //       ],
            //     ),
            //   },
            // ),
          ],
        ),
      ),
    );
  }

  // Widget buat field username
  Widget _buildUsernameField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: _usernameController,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Username',
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.person_outline, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Tolong Diisi Username'; // Pesan error yang friendly
          }
          return null;
        },
      ),
    );
  }

  // Widget buat field password dengan toggle visibility
  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: _obscurePassword,
        style: TextStyle(fontSize: 16),
        decoration: InputDecoration(
          labelText: 'Password',
          labelStyle: TextStyle(color: Colors.grey[600]),
          prefixIcon: Icon(Icons.lock_outline, color: Colors.grey[500]),
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword
                  ? Icons.visibility_outlined
                  : Icons.visibility_off_outlined,
              color: Colors.grey[500],
            ),
            onPressed: () {
              setState(() {
                _obscurePassword =
                    !_obscurePassword; // Toggle show/hide password
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Tolong Diisi Passwordnya'; // Pesan error yang casual
          }
          return null;
        },
      ),
    );
  }

  // Widget buat lupa password (masih kosong functionality-nya)
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: () {
          // TODO: Implement forgot password functionality
        },
        child: Text(
          'Lupa Password?',
          style: TextStyle(
            color: Color(0xFF667EEA),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // Widget buat tombol login dengan loading state
  Widget _buildLoginButton() {
    return Container(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login, // Disable ketika loading
        style: ElevatedButton.styleFrom(
          backgroundColor: Color(0xFF667EEA),
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: Color(0xFF667EEA).withOpacity(0.3),
        ),
        child: _isLoading
            ? SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Sign In',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
      ),
    );
  }
}
