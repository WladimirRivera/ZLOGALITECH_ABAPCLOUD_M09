*&---------------------------------------------------------------------*
*& ABAP Programacion Estructurada - Class 2
*& Section 8: Proposed exercise, worked solution
*& Input: 'ORD-2026-000451|john.smith@example.com|1250.50'
*& 1. SPLIT the string into its three components
*& 2. Extract year and serial from the order reference with PCRE + SUBMATCHES
*& 3. Validate the e-mail format with FIND REGEX
*& 4. Convert the amount to a P(2 decimals) type using EXACT
*& 5. Print a final summary built with a string template
*&---------------------------------------------------------------------*
CLASS zcl_02_06_exercise_solution DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

ENDCLASS.



CLASS zcl_02_06_exercise_solution IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== SECTION 8: PROPOSED EXERCISE - ORDER REFERENCE PARSING ===' ).

    DATA(lv_input) = |ORD-2026-000451\|john.smith@example.com\|1250.50|.
    out->write( |Input: { lv_input }| ).

    "--------------------------------------------------------------
    " Step 1: split the string into its three components
    "--------------------------------------------------------------
    DATA: lv_order_ref TYPE string,
          lv_email     TYPE string,
          lv_amount_str TYPE string.

    SPLIT lv_input AT '|' INTO lv_order_ref lv_email lv_amount_str.

    out->write( '--- Step 1: SPLIT ---' ).
    out->write( |Order ref: { lv_order_ref }| ).
    out->write( |E-mail:    { lv_email }| ).
    out->write( |Amount:    { lv_amount_str }| ).

    "--------------------------------------------------------------
    " Step 2: extract year and serial with PCRE + SUBMATCHES
    "--------------------------------------------------------------
    DATA: lv_year   TYPE string,
          lv_serial TYPE string.

    FIND REGEX 'ORD-(\d{4})-(\d+)' IN lv_order_ref
      SUBMATCHES lv_year lv_serial.

    out->write( '--- Step 2: SUBMATCHES ---' ).
    out->write( |Year: { lv_year }, Serial: { lv_serial }| ).

    "--------------------------------------------------------------
    " Step 3: validate the e-mail format with FIND REGEX
    "--------------------------------------------------------------
    FIND REGEX '^[\w.\-]+@[\w\-]+\.[a-zA-Z]{2,}$' IN lv_email.
    DATA(lv_email_valid) = xsdbool( sy-subrc = 0 ).

    out->write( '--- Step 3: FIND REGEX ---' ).
    out->write( |E-mail valid: '{ lv_email_valid }'| ).

    "--------------------------------------------------------------
    " Step 4: convert the amount to P(2 decimals) using EXACT
    "--------------------------------------------------------------
    DATA lv_amount TYPE p LENGTH 8 DECIMALS 2.

    out->write( '--- Step 4: EXACT ---' ).
    TRY.
        lv_amount = EXACT #( CONV decfloat34( lv_amount_str ) ).
        out->write( |Amount converted exactly: { lv_amount }| ).
      CATCH cx_sy_conversion_rounding INTO DATA(lx_error).
        out->write( 'EXACT raised CX_SY_CONVERSION_ROUNDING: precision would be lost.' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.

    "--------------------------------------------------------------
    " Step 5: final summary with a string template
    "--------------------------------------------------------------
    out->write( '--- Step 5: Summary ---' ).
    out->write( |Order { lv_order_ref } ({ lv_year }/{ lv_serial }) for { lv_email }| &&
                | (valid: { lv_email_valid }) - amount { lv_amount } EUR| ).
  ENDMETHOD.

ENDCLASS.
