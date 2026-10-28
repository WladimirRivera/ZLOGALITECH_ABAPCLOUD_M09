CLASS zcl_03_02_loops_and_exceptions DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS do_times           IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS do_until_exit      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS while_loop         IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS try_catch_single   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS try_catch_multiple IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_02_loops_and_exceptions IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 1: DO, WHILE, TRY/CATCH ===' ).
*    do_times( out ).
*    do_until_exit( out ).
*    while_loop( out ).
*    try_catch_single( out ).
    try_catch_multiple( out ).
  ENDMETHOD.

  METHOD do_times.
    out->write( '--- DO n TIMES ---' ).
    DATA lv_counter TYPE i.
    DO 5 TIMES.
      lv_counter = lv_counter + 1.
      out->write( |Iteration number { lv_counter }| ).
    ENDDO.
  ENDMETHOD.

  METHOD do_until_exit.
    out->write( '--- DO without TIMES, stopped with EXIT ---' ).
    DATA lv_pending_units TYPE i VALUE 30.
    DO.
      IF lv_pending_units <= 0.
        EXIT.
      ENDIF.
      lv_pending_units = lv_pending_units - 10.
      out->write( |Batch processed, { lv_pending_units } units left| ).
    ENDDO.
  ENDMETHOD.

  METHOD while_loop.
    out->write( '--- WHILE / ENDWHILE ---' ).
    DATA lv_pending_units TYPE i VALUE 30.
    WHILE lv_pending_units > 0.
      lv_pending_units = lv_pending_units - 10.
      out->write( |Batch processed, { lv_pending_units } units left| ).
    ENDWHILE.
  ENDMETHOD.

  METHOD try_catch_single.
    out->write( '--- TRY / CATCH: a single exception class ---' ).
    DATA lv_divisor TYPE i VALUE 0.
    DATA lv_result  TYPE i.

    TRY.
        lv_result = 100 / lv_divisor.
        lv_result = 100 / 0.
*     CATCH cx_sy_zerodivide.
     CATCH cx_root.
        out->write( 'Error: division by zero is not allowed' ).
    ENDTRY.
  ENDMETHOD.

  METHOD try_catch_multiple.
    out->write( '--- TRY / CATCH: several exception classes ---' ).

    TYPES ty_price TYPE p LENGTH 5 DECIMALS 2.
    DATA lt_prices TYPE STANDARD TABLE OF ty_price WITH EMPTY KEY.

    TRY.
        DATA(lv_price) = lt_prices[ 1 ].
        out->write( |Price: { lv_price }| ).
      CATCH cx_sy_itab_line_not_found.
        out->write( 'Error: the price table has no rows yet' ).
      CATCH cx_root INTO DATA(lx_error).
        out->write( |Unexpected error: { lx_error->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.
