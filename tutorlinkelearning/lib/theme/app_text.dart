import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type ramp from the TutorLink mobile design: Poppins carries titles and
/// button labels, Source Sans 3 carries body copy and metadata.
class TLText {
  const TLText._();

  // ── Poppins ────────────────────────────────────────────────────────────

  /// Onboarding headline — 26/700.
  static TextStyle display(Color c) => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Auth heading — 24/700.
  static TextStyle authTitle(Color c) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Screen title / greeting — 22/700.
  static TextStyle screenTitle(Color c) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Section heading — 18/700.
  static TextStyle sectionTitle(Color c) => GoogleFonts.poppins(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Card / list-item title — 15/600.
  static TextStyle cardTitle(Color c) => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// Primary button label — 16/600.
  static TextStyle button(Color c) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// Big figure (streak count, score) — 26/700.
  static TextStyle figure(Color c) => GoogleFonts.poppins(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: c,
      );

  // ── Source Sans 3 ──────────────────────────────────────────────────────

  /// Onboarding body — 16/400.
  static TextStyle lead(Color c) => GoogleFonts.sourceSans3(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: c,
      );

  /// Field text and standard body — 15/400.
  static TextStyle body(Color c) => GoogleFonts.sourceSans3(
        fontSize: 15,
        fontWeight: FontWeight.w400,
        color: c,
      );

  /// Subtitle / secondary copy — 14/400.
  static TextStyle sub(Color c) => GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c,
      );

  /// Emphasised inline link or label — 14/700.
  static TextStyle link(Color c) => GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Chip label — 13/600.
  static TextStyle chip(Color c) => GoogleFonts.sourceSans3(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// List metadata (rating, duration, timestamps) — 12/400.
  static TextStyle meta(Color c) => GoogleFonts.sourceSans3(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: c,
      );

  /// Status pill — 11/700.
  static TextStyle tag(Color c) => GoogleFonts.sourceSans3(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Inline validation message — 11.5/400.
  static TextStyle error(Color c) => GoogleFonts.sourceSans3(
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        height: 1.4,
        color: c,
      );
}
