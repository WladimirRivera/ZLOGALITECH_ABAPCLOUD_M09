*&---------------------------------------------------------------------*
*& ABAP Programacion Estructurada - Class 2
*& Section 6: PCRE regular expressions for validation and extraction
*&---------------------------------------------------------------------*
CLASS zcl_02_05_regex_pcre DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS find_replace_regex    IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS submatches_capture    IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS regex_class_matcher   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS best_practices        IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_02_05_regex_pcre IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== SECTION 6: PCRE REGULAR EXPRESSIONS ===' ).

    find_replace_regex( out ).
    submatches_capture( out ).
    regex_class_matcher( out ).
    best_practices( out ).
  ENDMETHOD.


  METHOD find_replace_regex.
    out->write( '--- 6.1 FIND and REPLACE with the REGEX addition ---' ).

    DATA: lv_email TYPE string VALUE 'john.smith@example.com',
          lv_valid TYPE abap_bool.

    FIND REGEX '^[\w.\-]+@[\w\-]+\.[a-zA-Z]{2,}$' IN lv_email.
    lv_valid = xsdbool( sy-subrc = 0 ).

    out->write( |Validating '{ lv_email }' -> valid: '{ lv_valid }'| ).

    DATA(lv_phone) = |Call me at 555-123-4567 or 555-987-6543|.

    REPLACE ALL OCCURRENCES OF REGEX '\d{3}-\d{3}-\d{4}'
      IN lv_phone WITH '[PHONE NUMBER]'.

    out->write( |After masking phone numbers -> '{ lv_phone }'| ).
  ENDMETHOD.


  METHOD submatches_capture.
    out->write( '--- 6.2 Capturing groups with SUBMATCHES ---' ).

    DATA: lv_order_ref TYPE string VALUE 'ORD-2026-000451',
          lv_year      TYPE string,
          lv_serial    TYPE string.

    FIND REGEX 'ORD-(\d{4})-(\d+)' IN lv_order_ref
      SUBMATCHES lv_year lv_serial.

    out->write( |'{ lv_order_ref }' -> year: '{ lv_year }', serial: '{ lv_serial }'| ).
  ENDMETHOD.


  METHOD regex_class_matcher.
    out->write( '--- 6.3 CL_ABAP_REGEX and CL_ABAP_MATCHER ---' ).

    DATA(lv_document_text) = |Invoices AB123456 and CD654321 were processed today|.

    DATA(lo_regex) = cl_abap_regex=>create_pcre(
      pattern     = '[A-Z]{2}\d{6}'
      ignore_case = abap_false ).

    DATA(lo_matcher) = lo_regex->create_matcher( text = lv_document_text ).

    WHILE lo_matcher->find_next( ) = abap_true.
      DATA(lv_match) = lo_matcher->get_submatch( 0 ).
      out->write( |Found reference: { lv_match }| ).
    ENDWHILE.
  ENDMETHOD.


  METHOD best_practices.
    out->write( '--- 6.4 Best practices when using PCRE ---' ).
    out->write( '- Compile once: if the same pattern runs many times (e.g. inside a loop' ).
    out->write( '  over an internal table), create CL_ABAP_REGEX once outside the loop' ).
    out->write( '  and reuse it, instead of repeating FIND REGEX on every iteration.' ).
    out->write( '- Always check SY-SUBRC after FIND: a non-zero value means no match,' ).
    out->write( '  so SUBMATCHES cannot be assumed to contain valid data.' ).
    out->write( '- Anchor the pattern (^ and $) when validating a full format (like an' ).
    out->write( '  e-mail address), but avoid anchors when extracting a match from a' ).
    out->write( '  longer free-text string.' ).
    out->write( '- Escape special characters (dots, dashes, parentheses) with a' ).
    out->write( '  backslash when they must be treated as literal text.' ).
  ENDMETHOD.

ENDCLASS.
