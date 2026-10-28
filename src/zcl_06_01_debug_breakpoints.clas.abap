CLASS zcl_06_01_debug_breakpoints DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES tt_flights TYPE STANDARD TABLE OF /dmo/flight WITH EMPTY KEY.

    METHODS load_flights
      RETURNING VALUE(rt_flights) TYPE tt_flights.

    METHODS calculate_occupancy
      IMPORTING is_flight         TYPE /dmo/flight
      RETURNING VALUE(rv_percent) TYPE decfloat16
      RAISING   cx_sy_zerodivide.

ENDCLASS.


CLASS zcl_06_01_debug_breakpoints IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 6.01: ADT DEBUGGER - BREAKPOINTS ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Static breakpoint ---' ).
    DATA(lt_flights) = load_flights( ).
    out->write( |Flights loaded from /DMO/FLIGHT: { lines( lt_flights ) }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Breakpoint inside a loop ---' ).
    DATA lv_lh_flights TYPE i.
    DATA lv_almost_full TYPE i.
    LOOP AT lt_flights INTO DATA(ls_flight).
      DATA(lv_occupancy) = calculate_occupancy( ls_flight ).
      IF ls_flight-carrier_id = 'LH'.
        lv_lh_flights += 1.
      ENDIF.
      IF lv_occupancy >= 90.
        lv_almost_full += 1.
      ENDIF.
    ENDLOOP.
    out->write( |Lufthansa (LH) flights: { lv_lh_flights }| ).
    out->write( |Flights with occupancy >= 90%: { lv_almost_full }| ).
    out->write( ' ' ).

    out->write( '--- Example 3: Conditional breakpoint ---' ).
    DATA(lv_matching_rows) = REDUCE i( INIT n = 0
                                       FOR ls_row IN lt_flights
                                       WHERE ( carrier_id = 'LH' AND seats_occupied > 100 )
                                       NEXT n = n + 1 ).
    out->write( |Matching rows: { lv_matching_rows } of { lines( lt_flights ) }| ).
    out->write( ' ' ).

    out->write( '--- Example 4: Exception breakpoint ---' ).
    DATA(ls_broken_flight) = VALUE /dmo/flight( carrier_id     = 'XX'
                                                connection_id  = '9999'
                                                seats_max      = 0
                                                seats_occupied = 50 ).
    TRY.
        DATA(lv_broken_occupancy) = calculate_occupancy( ls_broken_flight ).
        out->write( |Occupancy: { lv_broken_occupancy }| ).
      CATCH cx_sy_zerodivide INTO DATA(lx_zero).
        out->write( |Caught { cl_abap_typedescr=>describe_by_object_ref( lx_zero )->get_relative_name( ) }: { lx_zero->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD load_flights.
    SELECT FROM /dmo/flight
      FIELDS *
      ORDER BY carrier_id, connection_id, flight_date
      INTO TABLE @rt_flights.
  ENDMETHOD.


  METHOD calculate_occupancy.
    rv_percent = is_flight-seats_occupied * 100 / is_flight-seats_max.
  ENDMETHOD.

ENDCLASS.

