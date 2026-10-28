*&---------------------------------------------------------------------*
*& ABAP Programacion Estructurada - Class 2
*& Section 2: Arithmetic operations, type conversion, truncation,
*& rounding and forced conversions with CONV / EXACT
*&---------------------------------------------------------------------*
CLASS zcl_02_01_arithmetic_conv DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS basic_arithmetic          IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS division_modulo_power     IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS elementary_data_types     IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS implicit_explicit_conv    IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS truncation_and_rounding   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS conv_and_exact_operators  IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_02_01_arithmetic_conv IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== SECTION 2: ARITHMETIC, TYPE CONVERSION, ROUNDING, CONV/EXACT ===' ).

    basic_arithmetic( out ).
    division_modulo_power( out ).
    elementary_data_types( out ).
    implicit_explicit_conv( out ).
    truncation_and_rounding( out ).
    conv_and_exact_operators( out ).
  ENDMETHOD.


  METHOD basic_arithmetic.
    out->write( '--- 2.1 / 2.2 Arithmetic expressions: COMPUTE is optional (classic ABAP) ---' ).

    DATA: lv_num1        TYPE i VALUE 45,
          lv_num2        TYPE i VALUE 200,
          lv_percentage1 TYPE p LENGTH 3 DECIMALS 2,
          lv_percentage2 TYPE p LENGTH 3 DECIMALS 2.

    " COMPUTE is classic ABAP and not available in ABAP Cloud language version;
    " the plain assignment below is the only form allowed here, and gives the
    " exact same result as "COMPUTE lv_percentage1 = lv_num1 * 100 / lv_num2."
    lv_percentage1 = lv_num1 * 100 / lv_num2.
    lv_percentage2 = lv_num1 * 100 / lv_num2.

    out->write( |Result 1: { lv_percentage1 }| ).
    out->write( |Result 2: { lv_percentage2 }| ).

    out->write( '--- Dedicated keywords vs operators (same result) ---' ).
    out->write( 'ADD/SUBTRACT/MULTIPLY/DIVIDE still work but are flagged as the "old' ).
    out->write( 'variant" in ABAP Cloud; the operator form (+=, -=, *=, /=) is preferred.' ).

    DATA(lv_field) = 10.
    ADD 5 TO lv_field.
    out->write( |ADD 5 TO lv_field       -> { lv_field }| ).

    SUBTRACT 3 FROM lv_field.
    out->write( |SUBTRACT 3 FROM lv_field -> { lv_field }| ).

    MULTIPLY lv_field BY 2.
    out->write( |MULTIPLY lv_field BY 2   -> { lv_field }| ).

    DIVIDE lv_field BY 4.
    out->write( |DIVIDE lv_field BY 4     -> { lv_field }| ).

    lv_field += 100.
    lv_field = lv_field + 100.

    out->write( |lv_field += 100 (preferred shortcut) -> { lv_field }| ).
  ENDMETHOD.


  METHOD division_modulo_power.
    out->write( '--- 2.3 Integer division, remainder and power ---' ).

    DATA(lv_div_result) = 19 DIV 4.
    out->write( |19 DIV 4  -> { lv_div_result } (integer quotient)| ).

    DATA(lv_mod_result) = 5 MOD 2.
    out->write( |5 MOD 2   -> { lv_mod_result } (remainder)| ).

    DATA(lv_base) = 4.
    DATA(lv_square) = lv_base ** 2.
    DATA(lv_cube)   = lv_base ** 3.
    out->write( |4 ** 2 (square) -> { lv_square }| ).
    out->write( |4 ** 3 (cube)   -> { lv_cube }| ).

    DATA(lv_sqrt_result) = sqrt( 25 ).
    out->write( |sqrt( 25 ) -> { lv_sqrt_result }| ).
  ENDMETHOD.


  METHOD elementary_data_types.
    out->write( '--- 2.4 Elementary data types ---' ).

    DATA: lv_char   TYPE c LENGTH 10 VALUE 'HELLO',
          lv_num    TYPE i VALUE 42,
          lv_date   TYPE d VALUE '20260922',
          lv_time   TYPE t VALUE '153045',
          lv_amount TYPE p LENGTH 6 DECIMALS 2 VALUE '1250.75'.

    out->write( |C  (character, length 10): '{ lv_char }'| ).
    out->write( |I  (integer):              { lv_num }| ).
    out->write( |D  (date, AAAAMMDD):       { lv_date }| ).
    out->write( |T  (time, HHMMSS):         { lv_time }| ).
    out->write( |P  (packed, 2 decimals):   { lv_amount }| ).
  ENDMETHOD.


  METHOD implicit_explicit_conv.
    out->write( '--- 2.5 Implicit vs explicit conversion ---' ).

    DATA: lv_number TYPE i VALUE 10,
          lv_text   TYPE c LENGTH 3.

    lv_text = lv_number.  " Implicit conversion: integer to character string
    out->write( |Implicit: integer { lv_number } assigned to c(3) -> '{ lv_text }'| ).

    out->write( 'Explicit conversion needs an operator/function, e.g. CONV or a cast (=?).' ).
    out->write( 'See method conv_and_exact_operators for CONV / EXACT examples.' ).
  ENDMETHOD.


  METHOD truncation_and_rounding.
    out->write( '--- 2.6 Truncation vs rounding ---' ).

    DATA: lv_long_text  TYPE c LENGTH 10 VALUE 'REPORTING1',
          lv_short_text TYPE c LENGTH 5.

    lv_short_text = lv_long_text.  " Truncated
    out->write( |Truncation (text):   '{ lv_long_text }' -> '{ lv_short_text }'| ).

    DATA: lv_packed TYPE p LENGTH 5 DECIMALS 2 VALUE '123.45',
          lv_int    TYPE i.

    lv_int = lv_packed.  " Decimal part is lost, no rounding
    out->write( |Truncation (number): { lv_packed } -> { lv_int } (decimals simply dropped)| ).

    DATA: lv_packed_round TYPE p LENGTH 5 DECIMALS 2 VALUE '123.56',
          lv_int_rounded  TYPE i,
          lv_rounded      TYPE p LENGTH 5 DECIMALS 1.

    lv_int_rounded = lv_packed_round.  " Automatic rounding when target is integer
    out->write( |Automatic rounding:  { lv_packed_round } -> { lv_int_rounded }| ).

    lv_rounded = round( val = lv_packed_round dec = 1 ).
    out->write( |round( val = { lv_packed_round } dec = 1 ) -> { lv_rounded }| ).
  ENDMETHOD.


  METHOD conv_and_exact_operators.
    out->write( '--- 2.7 Forced conversions: CONV and EXACT ---' ).

    DATA(lv_quantity) = CONV decfloat34( '10.5' ).
    out->write( |CONV decfloat34( '10.5' ) -> { lv_quantity }| ).

    DATA: lv_amount     TYPE p LENGTH 8 DECIMALS 2,
          lv_source_str TYPE string VALUE '99.999'.

    lv_amount = CONV #( lv_source_str ).  " Type inferred (#) from lv_amount
    out->write( |CONV #( '99.999' ) into p(8,2) -> { lv_amount } (rounded silently)| ).

    DATA lv_exact_amount TYPE p LENGTH 8 DECIMALS 2.

    TRY.
        lv_exact_amount = EXACT #( CONV decfloat34( '123.456' ) ).
        out->write( |EXACT succeeded -> { lv_exact_amount }| ).
      CATCH cx_sy_conversion_rounding INTO DATA(lx_error).
        out->write( 'EXACT raised CX_SY_CONVERSION_ROUNDING: the conversion would lose precision.' ).
        out->write( lx_error->get_text( ) ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
