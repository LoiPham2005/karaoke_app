// ============================================================================
// FILE: lib/core/mixins/form_mixin.dart
// ============================================================================
import 'package:flutter/material.dart';

/// Mixin quản lý form với validation
mixin FormMixin<T extends StatefulWidget> on State<T> {
  final formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formData = {};
  bool _autoValidate = false;

  bool get autoValidate => _autoValidate;
  Map<String, dynamic> get formData => Map.unmodifiable(_formData);

  /// Validate form
  bool validateForm() {
    return formKey.currentState?.validate() ?? false;
  }

  /// Reset form
  void resetForm() {
    formKey.currentState?.reset();
    _formData.clear();
  }

  /// Save form
  void saveForm() {
    formKey.currentState?.save();
  }

  /// Validate và save form
  bool validateAndSave() {
    if (validateForm()) {
      saveForm();
      return true;
    }
    return false;
  }

  /// Set auto validate mode
  void setAutoValidate(bool value) {
    if (mounted) {
      setState(() => _autoValidate = value);
    }
  }

  /// Lưu field data
  void setFormField(String key, dynamic value) {
    _formData[key] = value;
  }

  /// Lấy field data
  dynamic getFormField(String key) => _formData[key];

  /// Clear một field cụ thể
  void clearFormField(String key) {
    _formData.remove(key);
  }

  /// Unfocus tất cả fields
  void unfocusAll() {
    FocusScope.of(context).unfocus();
  }
}
