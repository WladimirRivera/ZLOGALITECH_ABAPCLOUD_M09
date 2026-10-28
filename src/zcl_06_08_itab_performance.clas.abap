CLASS zcl_06_08_itab_performance DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS c_rows  TYPE i VALUE 20000.
    CONSTANTS c_reads TYPE i VALUE 5000.

    TYPES:
      BEGIN OF ty_booking_line,
        booking_key TYPE i,
        customer_id TYPE /dmo/customer_id,
        carrier_id  TYPE /dmo/carrier_id,
        price       TYPE /dmo/flight_price,
      END OF ty_booking_line,
      tt_standard TYPE STANDARD TABLE OF ty_booking_line WITH EMPTY KEY,
      tt_sorted   TYPE SORTED TABLE OF ty_booking_line WITH UNIQUE KEY booking_key,
      tt_hashed   TYPE HASHED TABLE OF ty_booking_line WITH UNIQUE KEY booking_key,

      BEGIN OF ty_measurement,
        table_kind   TYPE string,
        operation    TYPE string,
        milliseconds TYPE decfloat16,
        vs_fastest   TYPE string,
      END OF ty_measurement,
      tt_measurements TYPE STANDARD TABLE OF ty_measurement WITH EMPTY KEY.

    METHODS build_test_data
      RETURNING VALUE(rt_data) TYPE tt_standard.

    METHODS elapsed_ms
      IMPORTING iv_start     TYPE utclong
      RETURNING VALUE(rv_ms) TYPE decfloat16.

    METHODS lookup_key
      IMPORTING iv_index      TYPE i
      RETURNING VALUE(rv_key) TYPE i.

    METHODS add_ratios
      CHANGING ct_measurements TYPE tt_measurements.

ENDCLASS.


CLASS zcl_06_08_itab_performance IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA lt_standard TYPE tt_standard.
    DATA lt_sorted   TYPE tt_sorted.
    DATA lt_hashed   TYPE tt_hashed.
    DATA lt_fill     TYPE tt_measurements.
    DATA lt_read     TYPE tt_measurements.
    DATA lv_hits     TYPE i.

    out->write( '=== CLASS 6.08: INTERNAL TABLE PERFORMANCE - STANDARD vs SORTED vs HASHED ===' ).
    out->write( |Rows: { c_rows }, reads per table: { c_reads }| ).
    out->write( ' ' ).

    DATA(lt_source) = build_test_data( ).

    out->write( '--- Example 1: Filling the tables ---' ).
    DATA(lv_start) = utclong_current( ).
    lt_standard = lt_source.
    APPEND VALUE #( table_kind = `STANDARD` operation = `fill` milliseconds = elapsed_ms( lv_start ) ) TO lt_fill.

    lv_start = utclong_current( ).
    lt_sorted = lt_source.
    APPEND VALUE #( table_kind = `SORTED` operation = `fill` milliseconds = elapsed_ms( lv_start ) ) TO lt_fill.

    lv_start = utclong_current( ).
    lt_hashed = lt_source.
    APPEND VALUE #( table_kind = `HASHED` operation = `fill` milliseconds = elapsed_ms( lv_start ) ) TO lt_fill.

    add_ratios( CHANGING ct_measurements = lt_fill ).
    out->write( lt_fill ).
    out->write( ' ' ).

    out->write( '--- Example 2: Reading single rows by key ---' ).
    lv_start = utclong_current( ).
    DO c_reads TIMES.
      READ TABLE lt_standard WITH KEY booking_key = lookup_key( sy-index ) TRANSPORTING NO FIELDS.
      IF sy-subrc = 0.
        lv_hits += 1.
      ENDIF.
    ENDDO.
    APPEND VALUE #( table_kind = `STANDARD` operation = `READ linear search` milliseconds = elapsed_ms( lv_start ) ) TO lt_read.

    lv_start = utclong_current( ).
    DO c_reads TIMES.
      READ TABLE lt_standard WITH KEY booking_key = lookup_key( sy-index ) BINARY SEARCH TRANSPORTING NO FIELDS.
    ENDDO.
    APPEND VALUE #( table_kind = `STANDARD` operation = `READ BINARY SEARCH` milliseconds = elapsed_ms( lv_start ) ) TO lt_read.

    lv_start = utclong_current( ).
    DO c_reads TIMES.
      READ TABLE lt_sorted WITH TABLE KEY booking_key = lookup_key( sy-index ) TRANSPORTING NO FIELDS.
    ENDDO.
    APPEND VALUE #( table_kind = `SORTED` operation = `READ WITH TABLE KEY` milliseconds = elapsed_ms( lv_start ) ) TO lt_read.

    lv_start = utclong_current( ).
    DO c_reads TIMES.
      READ TABLE lt_hashed WITH TABLE KEY booking_key = lookup_key( sy-index ) TRANSPORTING NO FIELDS.
    ENDDO.
    APPEND VALUE #( table_kind = `HASHED` operation = `READ WITH TABLE KEY` milliseconds = elapsed_ms( lv_start ) ) TO lt_read.

    add_ratios( CHANGING ct_measurements = lt_read ).
    out->write( lt_read ).
    out->write( |Rows found: { lv_hits } of { c_reads }| ).
    out->write( ' ' ).

    out->write( '--- Example 3: Which table kind to choose ---' ).
  ENDMETHOD.


  METHOD build_test_data.
    SELECT FROM /dmo/booking
      FIELDS customer_id, carrier_id, flight_price
      INTO TABLE @DATA(lt_bookings).

    DATA(lv_source_rows) = lines( lt_bookings ).
    IF lv_source_rows = 0.
      RETURN.
    ENDIF.

    rt_data = VALUE #( FOR i = 1 UNTIL i > c_rows
                       LET ls_template = lt_bookings[ ( i - 1 ) MOD lv_source_rows + 1 ] IN
                       ( booking_key = i
                         customer_id = ls_template-customer_id
                         carrier_id  = ls_template-carrier_id
                         price       = ls_template-flight_price ) ).
  ENDMETHOD.


  METHOD elapsed_ms.
    rv_ms = utclong_diff( high = utclong_current( ) low = iv_start ) * 1000.
  ENDMETHOD.


  METHOD lookup_key.
    rv_key = ( iv_index * 7919 ) MOD c_rows + 1.
  ENDMETHOD.


  METHOD add_ratios.
    DATA(lv_fastest) = REDUCE decfloat16( INIT m = CONV decfloat16( 999999 )
                                          FOR ls IN ct_measurements
                                          NEXT m = nmin( val1 = m val2 = ls-milliseconds ) ).
    LOOP AT ct_measurements ASSIGNING FIELD-SYMBOL(<ls_measurement>).
      <ls_measurement>-vs_fastest = COND #( WHEN lv_fastest <= 0 THEN `-`
                                            ELSE |x { round( val = <ls_measurement>-milliseconds / lv_fastest dec = 1 ) }| ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

