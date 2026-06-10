// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_color_tokens.dart';

// **************************************************************************
// TailorAnnotationsGenerator
// **************************************************************************

mixin _$AppColorTokensTailorMixin on ThemeExtension<AppColorTokens> {
  Color get brandPrimary;
  Color get brandPrimaryLight;
  Color get brandSecondary;
  Color get bgPage;
  Color get bgCard;
  Color get bgInput;
  Color get bgModal;
  Color get textTitle;
  Color get textBody;
  Color get textSub;
  Color get textDisabled;
  Color get textOnPrimary;
  Color get borderDefault;
  Color get borderFocus;
  Color get statusSuccess;
  Color get statusWarning;
  Color get statusError;
  Color get statusInfo;
  Color get surfaceShadow;
  Color get surfaceDivider;
  Color get surfaceOverlay;

  @override
  AppColorTokens copyWith({
    Color? brandPrimary,
    Color? brandPrimaryLight,
    Color? brandSecondary,
    Color? bgPage,
    Color? bgCard,
    Color? bgInput,
    Color? bgModal,
    Color? textTitle,
    Color? textBody,
    Color? textSub,
    Color? textDisabled,
    Color? textOnPrimary,
    Color? borderDefault,
    Color? borderFocus,
    Color? statusSuccess,
    Color? statusWarning,
    Color? statusError,
    Color? statusInfo,
    Color? surfaceShadow,
    Color? surfaceDivider,
    Color? surfaceOverlay,
  }) {
    return AppColorTokens(
      brandPrimary: brandPrimary ?? this.brandPrimary,
      brandPrimaryLight: brandPrimaryLight ?? this.brandPrimaryLight,
      brandSecondary: brandSecondary ?? this.brandSecondary,
      bgPage: bgPage ?? this.bgPage,
      bgCard: bgCard ?? this.bgCard,
      bgInput: bgInput ?? this.bgInput,
      bgModal: bgModal ?? this.bgModal,
      textTitle: textTitle ?? this.textTitle,
      textBody: textBody ?? this.textBody,
      textSub: textSub ?? this.textSub,
      textDisabled: textDisabled ?? this.textDisabled,
      textOnPrimary: textOnPrimary ?? this.textOnPrimary,
      borderDefault: borderDefault ?? this.borderDefault,
      borderFocus: borderFocus ?? this.borderFocus,
      statusSuccess: statusSuccess ?? this.statusSuccess,
      statusWarning: statusWarning ?? this.statusWarning,
      statusError: statusError ?? this.statusError,
      statusInfo: statusInfo ?? this.statusInfo,
      surfaceShadow: surfaceShadow ?? this.surfaceShadow,
      surfaceDivider: surfaceDivider ?? this.surfaceDivider,
      surfaceOverlay: surfaceOverlay ?? this.surfaceOverlay,
    );
  }

  @override
  AppColorTokens lerp(
    covariant ThemeExtension<AppColorTokens>? other,
    double t,
  ) {
    if (other is! AppColorTokens) return this as AppColorTokens;
    return AppColorTokens(
      brandPrimary: Color.lerp(brandPrimary, other.brandPrimary, t)!,
      brandPrimaryLight: Color.lerp(
        brandPrimaryLight,
        other.brandPrimaryLight,
        t,
      )!,
      brandSecondary: Color.lerp(brandSecondary, other.brandSecondary, t)!,
      bgPage: Color.lerp(bgPage, other.bgPage, t)!,
      bgCard: Color.lerp(bgCard, other.bgCard, t)!,
      bgInput: Color.lerp(bgInput, other.bgInput, t)!,
      bgModal: Color.lerp(bgModal, other.bgModal, t)!,
      textTitle: Color.lerp(textTitle, other.textTitle, t)!,
      textBody: Color.lerp(textBody, other.textBody, t)!,
      textSub: Color.lerp(textSub, other.textSub, t)!,
      textDisabled: Color.lerp(textDisabled, other.textDisabled, t)!,
      textOnPrimary: Color.lerp(textOnPrimary, other.textOnPrimary, t)!,
      borderDefault: Color.lerp(borderDefault, other.borderDefault, t)!,
      borderFocus: Color.lerp(borderFocus, other.borderFocus, t)!,
      statusSuccess: Color.lerp(statusSuccess, other.statusSuccess, t)!,
      statusWarning: Color.lerp(statusWarning, other.statusWarning, t)!,
      statusError: Color.lerp(statusError, other.statusError, t)!,
      statusInfo: Color.lerp(statusInfo, other.statusInfo, t)!,
      surfaceShadow: Color.lerp(surfaceShadow, other.surfaceShadow, t)!,
      surfaceDivider: Color.lerp(surfaceDivider, other.surfaceDivider, t)!,
      surfaceOverlay: Color.lerp(surfaceOverlay, other.surfaceOverlay, t)!,
    );
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is AppColorTokens &&
            const DeepCollectionEquality().equals(
              brandPrimary,
              other.brandPrimary,
            ) &&
            const DeepCollectionEquality().equals(
              brandPrimaryLight,
              other.brandPrimaryLight,
            ) &&
            const DeepCollectionEquality().equals(
              brandSecondary,
              other.brandSecondary,
            ) &&
            const DeepCollectionEquality().equals(bgPage, other.bgPage) &&
            const DeepCollectionEquality().equals(bgCard, other.bgCard) &&
            const DeepCollectionEquality().equals(bgInput, other.bgInput) &&
            const DeepCollectionEquality().equals(bgModal, other.bgModal) &&
            const DeepCollectionEquality().equals(textTitle, other.textTitle) &&
            const DeepCollectionEquality().equals(textBody, other.textBody) &&
            const DeepCollectionEquality().equals(textSub, other.textSub) &&
            const DeepCollectionEquality().equals(
              textDisabled,
              other.textDisabled,
            ) &&
            const DeepCollectionEquality().equals(
              textOnPrimary,
              other.textOnPrimary,
            ) &&
            const DeepCollectionEquality().equals(
              borderDefault,
              other.borderDefault,
            ) &&
            const DeepCollectionEquality().equals(
              borderFocus,
              other.borderFocus,
            ) &&
            const DeepCollectionEquality().equals(
              statusSuccess,
              other.statusSuccess,
            ) &&
            const DeepCollectionEquality().equals(
              statusWarning,
              other.statusWarning,
            ) &&
            const DeepCollectionEquality().equals(
              statusError,
              other.statusError,
            ) &&
            const DeepCollectionEquality().equals(
              statusInfo,
              other.statusInfo,
            ) &&
            const DeepCollectionEquality().equals(
              surfaceShadow,
              other.surfaceShadow,
            ) &&
            const DeepCollectionEquality().equals(
              surfaceDivider,
              other.surfaceDivider,
            ) &&
            const DeepCollectionEquality().equals(
              surfaceOverlay,
              other.surfaceOverlay,
            ));
  }

  @override
  int get hashCode {
    return Object.hashAll([
      runtimeType.hashCode,
      const DeepCollectionEquality().hash(brandPrimary),
      const DeepCollectionEquality().hash(brandPrimaryLight),
      const DeepCollectionEquality().hash(brandSecondary),
      const DeepCollectionEquality().hash(bgPage),
      const DeepCollectionEquality().hash(bgCard),
      const DeepCollectionEquality().hash(bgInput),
      const DeepCollectionEquality().hash(bgModal),
      const DeepCollectionEquality().hash(textTitle),
      const DeepCollectionEquality().hash(textBody),
      const DeepCollectionEquality().hash(textSub),
      const DeepCollectionEquality().hash(textDisabled),
      const DeepCollectionEquality().hash(textOnPrimary),
      const DeepCollectionEquality().hash(borderDefault),
      const DeepCollectionEquality().hash(borderFocus),
      const DeepCollectionEquality().hash(statusSuccess),
      const DeepCollectionEquality().hash(statusWarning),
      const DeepCollectionEquality().hash(statusError),
      const DeepCollectionEquality().hash(statusInfo),
      const DeepCollectionEquality().hash(surfaceShadow),
      const DeepCollectionEquality().hash(surfaceDivider),
      const DeepCollectionEquality().hash(surfaceOverlay),
    ]);
  }
}

extension AppColorTokensBuildContextProps on BuildContext {
  AppColorTokens get appColorTokens =>
      Theme.of(this).extension<AppColorTokens>()!;
  Color get brandPrimary => appColorTokens.brandPrimary;
  Color get brandPrimaryLight => appColorTokens.brandPrimaryLight;
  Color get brandSecondary => appColorTokens.brandSecondary;
  Color get bgPage => appColorTokens.bgPage;
  Color get bgCard => appColorTokens.bgCard;
  Color get bgInput => appColorTokens.bgInput;
  Color get bgModal => appColorTokens.bgModal;
  Color get textTitle => appColorTokens.textTitle;
  Color get textBody => appColorTokens.textBody;
  Color get textSub => appColorTokens.textSub;
  Color get textDisabled => appColorTokens.textDisabled;
  Color get textOnPrimary => appColorTokens.textOnPrimary;
  Color get borderDefault => appColorTokens.borderDefault;
  Color get borderFocus => appColorTokens.borderFocus;
  Color get statusSuccess => appColorTokens.statusSuccess;
  Color get statusWarning => appColorTokens.statusWarning;
  Color get statusError => appColorTokens.statusError;
  Color get statusInfo => appColorTokens.statusInfo;
  Color get surfaceShadow => appColorTokens.surfaceShadow;
  Color get surfaceDivider => appColorTokens.surfaceDivider;
  Color get surfaceOverlay => appColorTokens.surfaceOverlay;
}
