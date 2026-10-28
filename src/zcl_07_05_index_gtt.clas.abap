CLASS zcl_07_05_index_gtt DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS c_reads TYPE i VALUE 500.

    METHODS elapsed_ms
      IMPORTING iv_start     TYPE utclong
      RETURNING VALUE(rv_ms) TYPE decfloat16.

ENDCLASS.


CLASS zcl_07_05_index_gtt IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 7.05: DATABASE INDEXES AND GLOBAL TEMPORARY TABLES ===' ).
    out->write( ' ' ).

    SELECT FROM /dmo/booking
      FIELDS travel_id, booking_id, customer_id
      ORDER BY travel_id, booking_id
      INTO TABLE @DATA(lt_keys)
      UP TO @c_reads ROWS.

    out->write( '--- Example 1: Access with the complete primary key (primary index) ---' ).
    DATA(lv_start) = utclong_current( ).
    LOOP AT lt_keys INTO DATA(ls_key).
      SELECT SINGLE FROM /dmo/booking
        FIELDS flight_price
        WHERE travel_id  = @ls_key-travel_id
          AND booking_id = @ls_key-booking_id
        INTO @DATA(lv_price).
    ENDLOOP.
    out->write( |{ c_reads } reads by travel_id + booking_id: { elapsed_ms( lv_start ) } ms| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Access with a non-key field (candidate for a secondary index) ---' ).
    DATA lv_rows TYPE i.
    lv_start = utclong_current( ).
    LOOP AT lt_keys INTO ls_key.
      SELECT FROM /dmo/booking
        FIELDS COUNT(*)
        WHERE customer_id = @ls_key-customer_id
        INTO @DATA(lv_count).
      lv_rows += lv_count.
    ENDLOOP.
    out->write( |{ c_reads } reads by customer_id: { elapsed_ms( lv_start ) } ms, { lv_rows } rows| ).
    out->write( ' ' ).

    out->write( '--- Example 3: Fill the global temporary table ZTB_07_05_GTT ---' ).
    INSERT ztb_07_05_gtt FROM ( SELECT FROM /dmo/flight
                                  FIELDS carrier_id,
                                         CAST( COUNT(*) AS INT4 )              AS flights,
                                         CAST( SUM( seats_occupied ) AS INT4 ) AS seats_occupied
                                  GROUP BY carrier_id ).
    out->write( |INSERT FROM subquery: sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 4: Use the GTT like any table (JOIN with /DMO/I_CARRIER) ---' ).
    SELECT FROM ztb_07_05_gtt AS stats
      INNER JOIN /dmo/i_carrier AS carrier ON carrier~AirlineID = stats~carrier_id
      FIELDS stats~carrier_id, carrier~Name, stats~flights, stats~seats_occupied
      ORDER BY stats~seats_occupied DESCENDING
      INTO TABLE @DATA(lt_statistics).
    out->write( lt_statistics ).
    out->write( ' ' ).

    out->write( '--- Example 5: Empty the GTT before the end of the database LUW ---' ).
    DELETE FROM ztb_07_05_gtt.
    out->write( |DELETE FROM ztb_07_05_gtt: sy-dbcnt = { sy-dbcnt }| ).
    SELECT FROM ztb_07_05_gtt
      FIELDS COUNT(*)
      INTO @DATA(lv_remaining).
    out->write( |Rows left in the GTT: { lv_remaining }| ).
  ENDMETHOD.


  METHOD elapsed_ms.
    rv_ms = utclong_diff( high = utclong_current( ) low = iv_start ) * 1000.
  ENDMETHOD.

ENDCLASS.

