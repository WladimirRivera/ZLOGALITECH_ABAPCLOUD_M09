CLASS zcl_06_09_secondary_keys DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_booking,
        travel_id     TYPE /dmo/travel_id,
        booking_id    TYPE /dmo/booking_id,
        customer_id   TYPE /dmo/customer_id,
        carrier_id    TYPE /dmo/carrier_id,
        connection_id TYPE /dmo/connection_id,
        flight_date   TYPE /dmo/flight_date,
        flight_price  TYPE /dmo/flight_price,
        currency_code TYPE /dmo/currency_code,
      END OF ty_booking,

      tt_bookings TYPE STANDARD TABLE OF ty_booking
        WITH NON-UNIQUE KEY travel_id booking_id
        WITH NON-UNIQUE SORTED KEY by_customer COMPONENTS customer_id
        WITH NON-UNIQUE SORTED KEY by_flight   COMPONENTS carrier_id connection_id flight_date
        WITH UNIQUE HASHED KEY     by_booking  COMPONENTS travel_id booking_id,

      tt_customers TYPE STANDARD TABLE OF /dmo/customer_id WITH EMPTY KEY,

      BEGIN OF ty_measurement,
        access       TYPE string,
        key_used     TYPE string,
        milliseconds TYPE decfloat16,
      END OF ty_measurement,
      tt_measurements TYPE STANDARD TABLE OF ty_measurement WITH EMPTY KEY.

    METHODS elapsed_ms
      IMPORTING iv_start     TYPE utclong
      RETURNING VALUE(rv_ms) TYPE decfloat16.

ENDCLASS.


CLASS zcl_06_09_secondary_keys IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    DATA lt_bookings     TYPE tt_bookings.
    DATA lt_measurements TYPE tt_measurements.
    DATA lv_rows_primary TYPE i.
    DATA lv_rows_second  TYPE i.

    SELECT FROM /dmo/booking
      FIELDS travel_id, booking_id, customer_id, carrier_id,
             connection_id, flight_date, flight_price, currency_code
      INTO TABLE @lt_bookings.

    SELECT FROM /dmo/booking
      FIELDS DISTINCT customer_id
      ORDER BY customer_id
      INTO TABLE @DATA(lt_customers).

    out->write( '=== CLASS 6.09: INTERNAL TABLE PERFORMANCE - SECONDARY KEYS ===' ).
    out->write( |Bookings: { lines( lt_bookings ) }, customers: { lines( lt_customers ) }| ).
    out->write( ' ' ).

    out->write( '--- Example 1: LOOP ... WHERE on a non-key field vs USING KEY ---' ).
    DATA(lv_start) = utclong_current( ).
    LOOP AT lt_customers INTO DATA(ls_customer).
      LOOP AT lt_bookings TRANSPORTING NO FIELDS WHERE customer_id = ls_customer-customer_id.
        lv_rows_primary += 1.
      ENDLOOP.
    ENDLOOP.
    APPEND VALUE #( access = |LOOP WHERE customer_id ({ lines( lt_customers ) } customers)| key_used = `none`
                    milliseconds = elapsed_ms( lv_start ) ) TO lt_measurements.

    lv_start = utclong_current( ).
    LOOP AT lt_customers INTO ls_customer.
      LOOP AT lt_bookings USING KEY by_customer TRANSPORTING NO FIELDS WHERE customer_id = ls_customer-customer_id.
        lv_rows_second += 1.
      ENDLOOP.
    ENDLOOP.
    APPEND VALUE #( access = |LOOP WHERE customer_id ({ lines( lt_customers ) } customers)| key_used = `BY_CUSTOMER`
                    milliseconds = elapsed_ms( lv_start ) ) TO lt_measurements.
    out->write( |Rows found: without key = { lv_rows_primary }, BY_CUSTOMER = { lv_rows_second }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: READ TABLE by travel/booking - primary standard key vs hashed secondary key ---' ).
    lv_start = utclong_current( ).
    LOOP AT lt_bookings INTO DATA(ls_booking) TO 2000.
      READ TABLE lt_bookings WITH KEY travel_id = ls_booking-travel_id booking_id = ls_booking-booking_id
           TRANSPORTING NO FIELDS ##PRIMKEY[BY_BOOKING].
    ENDLOOP.
    APPEND VALUE #( access = `READ travel_id + booking_id (2000 reads)` key_used = `primary key`
                    milliseconds = elapsed_ms( lv_start ) ) TO lt_measurements.

    lv_start = utclong_current( ).
    LOOP AT lt_bookings INTO ls_booking TO 2000.
      READ TABLE lt_bookings WITH KEY by_booking COMPONENTS travel_id = ls_booking-travel_id booking_id = ls_booking-booking_id
           TRANSPORTING NO FIELDS.
    ENDLOOP.
    APPEND VALUE #( access = `READ travel_id + booking_id (2000 reads)` key_used = `BY_BOOKING`
                    milliseconds = elapsed_ms( lv_start ) ) TO lt_measurements.

    out->write( lt_measurements ).
    out->write( ' ' ).

    out->write( '--- Example 3: Lazy index update of non-unique keys ---' ).
    DATA(lt_copy) = lt_bookings.
    APPEND VALUE #( travel_id = '99999999' booking_id = '0001' customer_id = '000001'
                    carrier_id = 'LH' connection_id = '0400' ) TO lt_copy.
    DATA(ls_first) = lt_copy[ 1 ].

    lv_start = utclong_current( ).
    READ TABLE lt_copy WITH KEY by_flight COMPONENTS carrier_id    = ls_first-carrier_id
                                                     connection_id = ls_first-connection_id
                                                     flight_date   = ls_first-flight_date
         TRANSPORTING NO FIELDS.
    DATA(lv_first_read) = elapsed_ms( lv_start ).

    lv_start = utclong_current( ).
    READ TABLE lt_copy WITH KEY by_flight COMPONENTS carrier_id    = ls_first-carrier_id
                                                     connection_id = ls_first-connection_id
                                                     flight_date   = ls_first-flight_date
         TRANSPORTING NO FIELDS.
    DATA(lv_second_read) = elapsed_ms( lv_start ).

    out->write( |1st READ USING BY_FLIGHT: { lv_first_read } ms| ).
    out->write( |2nd READ USING BY_FLIGHT: { lv_second_read } ms| ).
    out->write( ' ' ).

    out->write( '--- Example 4: Duplicate protection with a unique secondary key ---' ).
    TRY.
        INSERT VALUE #( travel_id = ls_first-travel_id booking_id = ls_first-booking_id ) INTO TABLE lt_copy.
        out->write( 'Inserted' ).
      CATCH cx_sy_itab_duplicate_key INTO DATA(lx_duplicate).
        out->write( |INSERT rejected: { lx_duplicate->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.


  METHOD elapsed_ms.
    rv_ms = utclong_diff( high = utclong_current( ) low = iv_start ) * 1000.
  ENDMETHOD.

ENDCLASS.

