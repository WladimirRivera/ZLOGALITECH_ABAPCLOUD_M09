CLASS zcl_04_03_conv_expression DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_04_03_conv_expression IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA: lv_units TYPE i.
    DATA: lv_text TYPE string.
    DATA: lv_number TYPE i.
    DATA: lv_price TYPE p LENGTH 5 DECIMALS 2.
    DATA: lv_result TYPE string.

    out->write( '=== BLOCK 3: CONV EXPRESSION - Type Conversion ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Integer to String ---' ).
    lv_units = 250.
    lv_text = CONV string( lv_units ).
    out->write( |Original (int): { lv_units }| ).
    out->write( |Converted (string): { lv_text }| ).
    out->write( |Type confirmed: text is now string| ).
    out->write( ' ' ).

    out->write( '--- Example 2: String to Numeric ---' ).
    lv_text = '42'.
    lv_number = CONV i( lv_text ).
    out->write( |Original (string): { lv_text }| ).
    out->write( |Converted (int): { lv_number }| ).
    out->write( |Calculation: { lv_number } + 8 = { lv_number + 8 }| ).
    out->write( ' ' ).

    out->write( '--- Example 3: Decimal to String ---' ).
    lv_price = '99.99'.
    lv_result = CONV string( lv_price ).
    out->write( |Original (decimal): { lv_price }| ).
    out->write( |Converted (string): { lv_result }| ).
    out->write( |Concatenation: Price is { lv_result } EUR| ).
    out->write( ' ' ).

    out->write( '--- Example 4: Conversion in Expression ---' ).
    lv_text = '15'.
    DATA: lv_calc TYPE i.
    lv_calc = CONV i( lv_text ) * 2.
    out->write( |Convert and calculate: { lv_text } * 2 = { lv_calc }| ).
    out->write( ' ' ).
    out->write( 'Conclusion: CONV ensures type-safe conversions!' ).

  ENDMETHOD.

ENDCLASS.
