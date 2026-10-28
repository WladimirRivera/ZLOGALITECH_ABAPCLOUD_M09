CLASS zcl_07_03_table_data DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES tt_reviews TYPE STANDARD TABLE OF ztb_07_03_review WITH EMPTY KEY.

    METHODS build_reviews_from_bookings
      IMPORTING iv_customer_id    TYPE /dmo/customer_id
      RETURNING VALUE(rt_reviews) TYPE tt_reviews.

ENDCLASS.


CLASS zcl_07_03_table_data IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 7.03: DATABASE TABLES - DEFINITION AND DATA ===' ).
    out->write( ' ' ).

    out->write( '--- Example 0: Start from an empty table ---' ).
    DELETE FROM ztb_07_03_review.
    out->write( |DELETE FROM ztb_07_03_review: sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 1: INSERT a single row ---' ).
    GET TIME STAMP FIELD DATA(lv_now).
    DATA(ls_review) = VALUE ztb_07_03_review( review_id     = '00000001'
                                              customer_id   = '000001'
                                              carrier_id    = 'LH'
                                              connection_id = '0400'
                                              seat_class    = 'B'
                                              rating        = '5'
                                              discount_pct  = '10.00'
                                              review_text   = 'Great service on board'
                                              created_by    = cl_abap_context_info=>get_user_technical_name( )
                                              created_at    = lv_now ).
    INSERT ztb_07_03_review FROM @ls_review.
    out->write( |INSERT single row: sy-subrc = { sy-subrc }, sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: INSERT the same key again ---' ).
    INSERT ztb_07_03_review FROM @ls_review.
    out->write( |INSERT duplicate key: sy-subrc = { sy-subrc }, sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 3: INSERT many rows from an internal table (data from /DMO/BOOKING) ---' ).
    DATA(lt_reviews) = build_reviews_from_bookings( '000253' ).
    INSERT ztb_07_03_review FROM TABLE @lt_reviews.
    out->write( |INSERT FROM TABLE: sy-subrc = { sy-subrc }, sy-dbcnt = { sy-dbcnt }| ).
    INSERT ztb_07_03_review FROM TABLE @lt_reviews ACCEPTING DUPLICATE KEYS.
    out->write( |INSERT FROM TABLE ... ACCEPTING DUPLICATE KEYS: sy-subrc = { sy-subrc }, sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 4: UPDATE with SET and WHERE ---' ).
    UPDATE ztb_07_03_review
      SET rating = '5', review_text = 'Upgraded: excellent business class'
      WHERE seat_class = 'B'.
    out->write( |UPDATE ... WHERE seat_class = 'B': sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 5: MODIFY (update existing + insert new) ---' ).
    DATA lt_modify TYPE tt_reviews.
    APPEND VALUE #( BASE ls_review rating = '4' ) TO lt_modify.
    APPEND VALUE #( BASE ls_review review_id = '00000099' customer_id = '000002' rating = '3' ) TO lt_modify.
    MODIFY ztb_07_03_review FROM TABLE @lt_modify.
    out->write( |MODIFY FROM TABLE (1 existing + 1 new): sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 6: DELETE with WHERE ---' ).
    DELETE FROM ztb_07_03_review WHERE rating < '3'.
    out->write( |DELETE ... WHERE rating < 3: sy-dbcnt = { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Example 7: Final content of ZTB_07_03_REVIEW ---' ).
    SELECT FROM ztb_07_03_review
      FIELDS review_id, customer_id, carrier_id, connection_id, flight_date,
             seat_class, rating, discount_pct, review_text
      ORDER BY review_id
      INTO TABLE @DATA(lt_final).
    out->write( lt_final ).

    SELECT FROM ztb_07_03_review
      FIELDS carrier_id,
             COUNT(*)                                       AS reviews,
             AVG( CAST( rating AS INT4 ) AS DEC( 3, 2 ) )   AS average_rating
      GROUP BY carrier_id
      ORDER BY carrier_id
      INTO TABLE @DATA(lt_summary).
    out->write( lt_summary ).
  ENDMETHOD.


  METHOD build_reviews_from_bookings.
    SELECT FROM /dmo/booking
      FIELDS travel_id, booking_id, customer_id, carrier_id, connection_id,
             flight_date, flight_price
      WHERE customer_id = @iv_customer_id
      ORDER BY flight_date
      INTO TABLE @DATA(lt_bookings).

    GET TIME STAMP FIELD DATA(lv_now).
    DATA(lv_user) = cl_abap_context_info=>get_user_technical_name( ).

    rt_reviews = VALUE #( FOR ls_booking IN lt_bookings INDEX INTO lv_index
                          ( review_id     = |{ 100 + lv_index WIDTH = 8 ALIGN = RIGHT PAD = '0' }|
                            travel_id     = ls_booking-travel_id
                            booking_id    = ls_booking-booking_id
                            customer_id   = ls_booking-customer_id
                            carrier_id    = ls_booking-carrier_id
                            connection_id = ls_booking-connection_id
                            flight_date   = ls_booking-flight_date
                            seat_class    = COND #( WHEN ls_booking-flight_price >= 3000 THEN 'F'
                                                    WHEN ls_booking-flight_price >= 1000 THEN 'B'
                                                    ELSE 'E' )
                            rating        = CONV #( lv_index MOD 5 + 1 )
                            review_text   = |Review of flight { ls_booking-carrier_id } { ls_booking-connection_id }|
                            created_by    = lv_user
                            created_at    = lv_now ) ).
  ENDMETHOD.

ENDCLASS.

