CLASS zcl_04_07_reduce_expression DEFINITION
  PUBLIC FINAL CREATE PUBLIC.
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.
ENDCLASS.

CLASS zcl_04_07_reduce_expression IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
    DATA gt_values TYPE TABLE OF i.
    DATA lv_sum TYPE i.

    out->write( '=== REDUCE Expression ===' ).
    out->write( ' ' ).

    gt_values = VALUE #( ( 10 ) ( 20 ) ( 30 ) ( 40 ) ).

    lv_sum = REDUCE i( INIT s = 0
                       FOR v IN gt_values
                       NEXT s = s + v ).

    out->write( |Sum of 10, 20, 30, 40 = { lv_sum }| ).
    out->write( 'REDUCE accumulates values in one expression!' ).

  ENDMETHOD.
ENDCLASS.
