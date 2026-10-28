CLASS zcl_06_02_debug_watch_navigate DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES tt_bookings TYPE STANDARD TABLE OF /dmo/booking WITH EMPTY KEY.
    TYPES tt_log      TYPE STANDARD TABLE OF string WITH EMPTY KEY.

    TYPES:
      BEGIN OF ty_customer_summary,
        customer_id   TYPE /dmo/customer_id,
        bookings      TYPE i,
        total_revenue TYPE decfloat34,
        category      TYPE string,
      END OF ty_customer_summary.

    DATA mv_total_revenue TYPE decfloat34.
    DATA mv_category      TYPE string.
    DATA mt_category_log  TYPE tt_log.

    METHODS find_top_customer
      RETURNING VALUE(rv_customer_id) TYPE /dmo/customer_id.

    METHODS build_summary
      IMPORTING iv_customer_id    TYPE /dmo/customer_id
      RETURNING VALUE(rs_summary) TYPE ty_customer_summary.

    METHODS get_bookings
      IMPORTING iv_customer_id     TYPE /dmo/customer_id
      RETURNING VALUE(rt_bookings) TYPE tt_bookings.

    METHODS sum_revenue
      IMPORTING it_bookings       TYPE tt_bookings
      RETURNING VALUE(rv_revenue) TYPE decfloat34.

    METHODS classify
      IMPORTING iv_revenue         TYPE decfloat34
      RETURNING VALUE(rv_category) TYPE string.

ENDCLASS.


CLASS zcl_06_02_debug_watch_navigate IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 6.02: ADT DEBUGGER - WATCHPOINTS, NAVIGATION AND SAVED SETUP ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Navigation through the call stack ---' ).
    DATA(lv_customer_id) = find_top_customer( ).
    DATA(ls_summary) = build_summary( lv_customer_id ).
    out->write( |Customer { ls_summary-customer_id }: { ls_summary-bookings } EUR bookings, revenue { ls_summary-total_revenue } EUR, category { ls_summary-category }| ).
    out->write( ' ' ).

    out->write( '--- Example 2: Watchpoint on an attribute ---' ).
    LOOP AT mt_category_log INTO DATA(lv_log_line).
      out->write( |   { lv_log_line }| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 3: Watchpoint with condition ---' ).
    out->write( |Final running total: { mv_total_revenue } EUR| ).
    out->write( ' ' ).

    out->write( '--- Example 4: Reusing a debugging setup between sessions ---' ).
  ENDMETHOD.


  METHOD find_top_customer.
    SELECT FROM /dmo/booking
      FIELDS customer_id,
             COUNT(*) AS booking_count
      WHERE currency_code = 'EUR'
      GROUP BY customer_id
      ORDER BY booking_count DESCENDING, customer_id
      INTO TABLE @DATA(lt_ranking)
      UP TO 1 ROWS.

    rv_customer_id = VALUE #( lt_ranking[ 1 ]-customer_id OPTIONAL ).
  ENDMETHOD.


  METHOD build_summary.
    DATA(lt_bookings) = get_bookings( iv_customer_id ).
    DATA(lv_revenue)  = sum_revenue( lt_bookings ).

    rs_summary = VALUE #( customer_id   = iv_customer_id
                          bookings      = lines( lt_bookings )
                          total_revenue = lv_revenue
                          category      = mv_category ).
  ENDMETHOD.


  METHOD get_bookings.
    SELECT FROM /dmo/booking
      FIELDS *
      WHERE customer_id   = @iv_customer_id
        AND currency_code = 'EUR'
      ORDER BY booking_date
      INTO TABLE @rt_bookings.
  ENDMETHOD.


  METHOD sum_revenue.
    CLEAR: mv_total_revenue, mv_category, mt_category_log.

    LOOP AT it_bookings INTO DATA(ls_booking).
      mv_total_revenue += ls_booking-flight_price.

      DATA(lv_new_category) = classify( mv_total_revenue ).
      IF lv_new_category <> mv_category.
        APPEND |Booking { ls_booking-travel_id }/{ ls_booking-booking_id }: { mv_category } -> { lv_new_category } (total { mv_total_revenue })|
          TO mt_category_log.
        mv_category = lv_new_category.
      ENDIF.
    ENDLOOP.

    rv_revenue = mv_total_revenue.
  ENDMETHOD.


  METHOD classify.
    rv_category = COND #( WHEN iv_revenue < 10000 THEN `BRONZE`
                          WHEN iv_revenue < 25000 THEN `SILVER`
                          ELSE                         `GOLD` ).
  ENDMETHOD.

ENDCLASS.

