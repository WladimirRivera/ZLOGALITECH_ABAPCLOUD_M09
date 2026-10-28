CLASS zcl_06_03_error_diagnosis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES tt_flights TYPE STANDARD TABLE OF /dmo/flight WITH EMPTY KEY.

    DATA mt_flights TYPE tt_flights.
    DATA mo_out     TYPE REF TO if_oo_adt_classrun_out.

    METHODS case_1_unchecked_read.
    METHODS case_2_case_sensitive_search.
    METHODS case_3_division_by_zero.
    METHODS case_4_line_not_found.
    METHODS case_5_arithmetic_overflow.

    METHODS print_error_position
      IMPORTING ix_error TYPE REF TO cx_root.

ENDCLASS.


CLASS zcl_06_03_error_diagnosis IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    mo_out = out.

    SELECT FROM /dmo/flight
      FIELDS *
      ORDER BY carrier_id, connection_id, flight_date
      INTO TABLE @mt_flights.

    out->write( '=== CLASS 6.03: DIAGNOSING REAL ERRORS - FROM SYMPTOM TO CAUSE ===' ).
    out->write( ' ' ).

    case_1_unchecked_read( ).
    case_2_case_sensitive_search( ).
    case_3_division_by_zero( ).
    case_4_line_not_found( ).
    case_5_arithmetic_overflow( ).
  ENDMETHOD.


  METHOD case_1_unchecked_read.
    mo_out->write( '--- Case 1: A price is shown for an airline that has no flights ---' ).

    DATA ls_flight TYPE /dmo/flight.
    READ TABLE mt_flights INTO ls_flight INDEX 1.
    READ TABLE mt_flights INTO ls_flight WITH KEY carrier_id = 'ZZ'.
    DATA(lv_subrc) = sy-subrc.

    mo_out->write( |Before: price for airline ZZ = { ls_flight-price } { ls_flight-currency_code }| ).
    mo_out->write( |        sy-subrc = { lv_subrc }, ls_flight-carrier_id = { ls_flight-carrier_id }| ).

    DATA(ls_fixed) = VALUE #( mt_flights[ carrier_id = 'ZZ' ] OPTIONAL ).
    mo_out->write( |After : airline ZZ found = { COND #( WHEN ls_fixed IS INITIAL THEN `no` ELSE `yes` ) }| ).
    mo_out->write( ' ' ).
  ENDMETHOD.


  METHOD case_2_case_sensitive_search.
    mo_out->write( '--- Case 2: Searching a customer by last name returns nothing ---' ).

    DATA(lv_search_input) = `BUCHHOLM`.
    SELECT FROM /dmo/customer
      FIELDS COUNT(*)
      WHERE last_name = @lv_search_input
      INTO @DATA(lv_found_buggy).

    mo_out->write( |Before: customers with last name '{ lv_search_input }' = { lv_found_buggy }| ).

    SELECT FROM /dmo/customer
      FIELDS COUNT(*)
      WHERE upper( last_name ) = @lv_search_input
      INTO @DATA(lv_found_fixed).
    mo_out->write( |After : customers with last name '{ lv_search_input }' = { lv_found_fixed }| ).
    mo_out->write( ' ' ).
  ENDMETHOD.


  METHOD case_3_division_by_zero.
    mo_out->write( '--- Case 3: Growth report dumps for a brand-new route ---' ).

    DATA(lv_seats_last_year) = 0.
    DATA(lv_seats_this_year) = VALUE #( mt_flights[ 1 ]-seats_occupied OPTIONAL ).

    TRY.
        DATA(lv_growth) = ( lv_seats_this_year - lv_seats_last_year ) * 100 / lv_seats_last_year.
        mo_out->write( |Growth: { lv_growth }%| ).
      CATCH cx_sy_zerodivide INTO DATA(lx_zero).
        mo_out->write( |Before: { lx_zero->get_text( ) }| ).
        print_error_position( lx_zero ).
    ENDTRY.

    lv_growth = COND #( WHEN lv_seats_last_year = 0 THEN 0
                        ELSE ( lv_seats_this_year - lv_seats_last_year ) * 100 / lv_seats_last_year ).
    mo_out->write( |After : growth = { lv_growth }%| ).
    mo_out->write( ' ' ).
  ENDMETHOD.


  METHOD case_4_line_not_found.
    mo_out->write( '--- Case 4: Program stops when reading a connection that is not in the table ---' ).

    TRY.
        DATA(lv_price) = mt_flights[ carrier_id = 'LH' connection_id = '9999' ]-price.
        mo_out->write( |Price: { lv_price }| ).
      CATCH cx_sy_itab_line_not_found INTO DATA(lx_not_found).
        mo_out->write( |Before: { lx_not_found->get_text( ) }| ).
        print_error_position( lx_not_found ).
    ENDTRY.

    IF line_exists( mt_flights[ carrier_id = 'LH' connection_id = '9999' ] ).
      lv_price = mt_flights[ carrier_id = 'LH' connection_id = '9999' ]-price.
    ENDIF.
    mo_out->write( |After : price = { lv_price }| ).
    mo_out->write( ' ' ).
  ENDMETHOD.


  METHOD case_5_arithmetic_overflow.
    mo_out->write( '--- Case 5: Revenue total for American Airlines (USD) aborts ---' ).

    DATA lv_revenue_small TYPE p LENGTH 4 DECIMALS 2.
    TRY.
        LOOP AT mt_flights INTO DATA(ls_flight) WHERE carrier_id = 'AA'.
          lv_revenue_small += ls_flight-price * ls_flight-seats_occupied.
        ENDLOOP.
        mo_out->write( |Revenue: { lv_revenue_small }| ).
      CATCH cx_sy_arithmetic_overflow INTO DATA(lx_overflow).
        mo_out->write( |Before: { lx_overflow->get_text( ) }| ).
        print_error_position( lx_overflow ).
    ENDTRY.

    DATA lv_revenue TYPE decfloat34.
    LOOP AT mt_flights INTO ls_flight WHERE carrier_id = 'AA'.
      lv_revenue += ls_flight-price * ls_flight-seats_occupied.
    ENDLOOP.
    mo_out->write( |After : revenue = { lv_revenue } USD| ).
    mo_out->write( ' ' ).
  ENDMETHOD.


  METHOD print_error_position.
    ix_error->get_source_position( IMPORTING include_name = DATA(lv_include)
                                             source_line  = DATA(lv_line) ).
    mo_out->write( |Where   : { cl_abap_typedescr=>describe_by_object_ref( ix_error )->get_relative_name( ) } raised in { lv_include }, line { lv_line }| ).
  ENDMETHOD.

ENDCLASS.

