import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Type ramp from the admin design: Poppins carries titles, numbers and
/// button labels; Source Sans 3 carries everything you actually read.
class TLText {
  const TLText._();

  // ── Poppins ────────────────────────────────────────────────────────────

  /// Sign-in panel wordmark — 30/700.
  static TextStyle brand(Color c) => GoogleFonts.poppins(
        fontSize: 30,
        fontWeight: FontWeight.w700,
        height: 1.25,
        color: c,
      );

  /// Page heading — 21/700.
  static TextStyle pageTitle(Color c) => GoogleFonts.poppins(
        fontSize: 21,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Auth form heading — 22/700.
  static TextStyle authTitle(Color c) => GoogleFonts.poppins(
        fontSize: 22,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Stat card figure — 24/700.
  static TextStyle statValue(Color c) => GoogleFonts.poppins(
        fontSize: 24,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Card / panel heading — 14/600.
  static TextStyle cardTitle(Color c) => GoogleFonts.poppins(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// Primary button label — 14.5/600.
  static TextStyle button(Color c) => GoogleFonts.poppins(
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// Compact button label — 13/600.
  static TextStyle buttonSm(Color c) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// Sidebar brand lockup — 15/700.
  static TextStyle sidebarBrand(Color c) => GoogleFonts.poppins(
        fontSize: 15,
        fontWeight: FontWeight.w700,
        color: c,
      );

  // ── Source Sans 3 ──────────────────────────────────────────────────────

  /// Default body — 14/400.
  static TextStyle body(Color c) => GoogleFonts.sourceSans3(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: c,
      );

  /// Emphasised body / table cell — 13.5/600.
  static TextStyle bodyStrong(Color c) => GoogleFonts.sourceSans3(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// Page subtitle and secondary copy — 13/400.
  static TextStyle sub(Color c) => GoogleFonts.sourceSans3(
        fontSize: 13,
        fontWeight: FontWeight.w400,
        color: c,
      );

  /// Nav row label — 13.5/600.
  static TextStyle navLabel(Color c) => GoogleFonts.sourceSans3(
        fontSize: 13.5,
        fontWeight: FontWeight.w600,
        color: c,
      );

  /// Caption / timestamp — 11.5/400.
  static TextStyle caption(Color c) => GoogleFonts.sourceSans3(
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        color: c,
      );

  /// Sidebar group header — 11/700, letterspaced, uppercased at the call site.
  static TextStyle groupHeader(Color c) => GoogleFonts.sourceSans3(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.6,
        color: c,
      );

  /// Pill / tag text — 10.5/700.
  static TextStyle tag(Color c) => GoogleFonts.sourceSans3(
        fontSize: 10.5,
        fontWeight: FontWeight.w700,
        color: c,
      );

  /// Inline validation message — 11.5/400.
  static TextStyle error(Color c) => GoogleFonts.sourceSans3(
        fontSize: 11.5,
        fontWeight: FontWeight.w400,
        height: 1.35,
        color: c,
      );
}
