import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import '../widgets/custom_app_bar.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _companyController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;
  bool _acceptTerms = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _companyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthCubit, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          setState(() {
            _isLoading = true;
          });
        } else {
          setState(() {
            _isLoading = false;
          });

          if (state is AuthRegistrationSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('สมัครสมาชิกสำเร็จ'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pushReplacementNamed(context, '/login');
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('เกิดข้อผิดพลาด: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        }
      },
      child: Scaffold(
        appBar: const CustomAppBar(title: 'สมัครสมาชิก'),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcomeSection(),
                const SizedBox(height: 32),
                _buildPersonalInfoSection(),
                const SizedBox(height: 24),
                _buildAccountInfoSection(),
                const SizedBox(height: 24),
                _buildTermsSection(),
                const SizedBox(height: 32),
                _buildRegisterButton(),
                const SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWelcomeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'ยินดีต้อนรับสู่ SML Market',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Text(
          'สร้างบัญชีใหม่เพื่อเริ่มต้นการเลือกซื้อสินค้าคุณภาพ',
          style: TextStyle(fontSize: 16, color: Colors.grey[600]),
        ),
      ],
    );
  }

  Widget _buildPersonalInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลส่วนตัว',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _firstNameController,
                    decoration: const InputDecoration(
                      labelText: 'ชื่อ *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'กรุณากรอกชื่อ';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    controller: _lastNameController,
                    decoration: const InputDecoration(
                      labelText: 'นามสกุล *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value?.isEmpty ?? true) {
                        return 'กรุณากรอกนามสกุล';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'หมายเลขโทรศัพท์ *',
                border: OutlineInputBorder(),
                prefixText: '+66 ',
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณากรอกหมายเลขโทรศัพท์';
                }
                if (value!.length < 9) {
                  return 'หมายเลขโทรศัพท์ไม่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _companyController,
              decoration: const InputDecoration(
                labelText: 'ชื่อบริษัท (ไม่บังคับ)',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'ข้อมูลบัญชี',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _usernameController,
              decoration: const InputDecoration(
                labelText: 'ชื่อผู้ใช้ *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                hintText: 'ตัวอักษรและตัวเลขเท่านั้น',
              ),
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณากรอกชื่อผู้ใช้';
                }
                if (value!.length < 3) {
                  return 'ชื่อผู้ใช้ต้องมีอย่างน้อย 3 ตัวอักษร';
                }
                if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
                  return 'ชื่อผู้ใช้ต้องเป็นตัวอักษร ตัวเลข หรือ _ เท่านั้น';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'อีเมล *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.email),
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณากรอกอีเมล';
                }
                if (!RegExp(
                  r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                ).hasMatch(value!)) {
                  return 'รูปแบบอีเมลไม่ถูกต้อง';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(
                labelText: 'รหัสผ่าน *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isPasswordVisible = !_isPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isPasswordVisible,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณากรอกรหัสผ่าน';
                }
                if (value!.length < 6) {
                  return 'รหัสผ่านต้องมีอย่างน้อย 6 ตัวอักษร';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _confirmPasswordController,
              decoration: InputDecoration(
                labelText: 'ยืนยันรหัสผ่าน *',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.lock_outline),
                suffixIcon: IconButton(
                  icon: Icon(
                    _isConfirmPasswordVisible
                        ? Icons.visibility
                        : Icons.visibility_off,
                  ),
                  onPressed: () {
                    setState(() {
                      _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                    });
                  },
                ),
              ),
              obscureText: !_isConfirmPasswordVisible,
              validator: (value) {
                if (value?.isEmpty ?? true) {
                  return 'กรุณายืนยันรหัสผ่าน';
                }
                if (value != _passwordController.text) {
                  return 'รหัสผ่านไม่ตรงกัน';
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTermsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CheckboxListTile(
              value: _acceptTerms,
              onChanged: (value) {
                setState(() {
                  _acceptTerms = value ?? false;
                });
              },
              title: const Text(
                'ฉันยอมรับข้อกำหนดและเงื่อนไข',
                style: TextStyle(fontSize: 14),
              ),
              controlAffinity: ListTileControlAffinity.leading,
              contentPadding: EdgeInsets.zero,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextButton(
                    onPressed: () {
                      _showTermsDialog();
                    },
                    child: const Text('อ่านข้อกำหนดและเงื่อนไข'),
                  ),
                  TextButton(
                    onPressed: () {
                      _showPrivacyDialog();
                    },
                    child: const Text('อ่านนโยบายความเป็นส่วนตัว'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading || !_acceptTerms ? null : _handleRegister,
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
        child: _isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'สมัครสมาชิก',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text('มีบัญชีอยู่แล้ว? '),
          TextButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/login');
            },
            child: const Text('เข้าสู่ระบบ'),
          ),
        ],
      ),
    );
  }

  void _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('กรุณายอมรับข้อกำหนดและเงื่อนไข')),
      );
      return;
    }

    // Use AuthCubit to register
    context.read<AuthCubit>().register(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
    );
  }

  void _showTermsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('ข้อกำหนดและเงื่อนไข'),
        content: const SingleChildScrollView(
          child: Text(
            'ข้อกำหนดและเงื่อนไขการใช้งาน SML Market\n\n'
            '1. ผู้ใช้ต้องให้ข้อมูลที่ถูกต้องและครบถ้วน\n'
            '2. ผู้ใช้ต้องรับผิดชอบในการรักษาความปลอดภัยของบัญชี\n'
            '3. ห้ามใช้บริการในการกระทำที่ผิดกฎหมาย\n'
            '4. บริษัทขอสงวนสิทธิ์ในการเปลี่ยนแปลงข้อกำหนด\n'
            '5. การใช้บริการถือว่ายอมรับข้อกำหนดนี้\n\n'
            'สอบถามเพิ่มเติมได้ที่ support@smlmarket.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }

  void _showPrivacyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('นโยบายความเป็นส่วนตัว'),
        content: const SingleChildScrollView(
          child: Text(
            'นโยบายความเป็นส่วนตัว SML Market\n\n'
            '1. การเก็บรวบรวมข้อมูล\n'
            '- ข้อมูลส่วนตัวที่จำเป็นสำหรับการให้บริการ\n'
            '- ข้อมูลการใช้งานเพื่อปรับปรุงบริการ\n\n'
            '2. การใช้ข้อมูล\n'
            '- เพื่อให้บริการตามที่ร้องขอ\n'
            '- เพื่อการติดต่อสื่อสาร\n'
            '- เพื่อปรับปรุงบริการ\n\n'
            '3. การรักษาความปลอดภัย\n'
            '- ใช้เทคโนโลยีเข้ารหัสข้อมูล\n'
            '- จำกัดการเข้าถึงข้อมูลเฉพาะผู้ที่จำเป็น\n\n'
            'สอบถามเพิ่มเติมได้ที่ privacy@smlmarket.com',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('ปิด'),
          ),
        ],
      ),
    );
  }
}
