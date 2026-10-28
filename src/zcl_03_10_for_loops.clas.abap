CLASS zcl_03_10_for_loops DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_03_10_for_loops IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA gt_numbers TYPE TABLE OF i.

    out->write( '=== FOR LOOPS ===' ).
    out->write( ' ' ).

    out->write( 'Example: FOR with THEN UNTIL' ).
    gt_numbers = VALUE #(
      FOR i = 1 THEN i + 1 UNTIL i > 5 ( i )
    ).
    out->write( |Created numbers 1-5: { lines( gt_numbers ) } items| ).

    out->write( 'FOR loops build tables efficiently!' ).

    DATA: lr_CITY     TYPE RANGE OF /dmo/agency-city.

  " 1. Preparar Rango de Materiales
  lr_CITY = VALUE #( FOR item IN gt_numbers
                      ( sign = 'I' option = 'EQ' low = item ) ).

    out->write( lr_CITY ).

  ENDMETHOD.
ENDCLASS.
