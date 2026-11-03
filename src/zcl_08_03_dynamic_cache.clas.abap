CLASS zcl_08_03_dynamic_cache DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_measure,
        query       TYPE string,
        runs        TYPE i,
        first_ms    TYPE decfloat34,
        average_ms  TYPE decfloat34,
        fastest_ms  TYPE decfloat34,
        result_rows TYPE i,
      END OF ty_measure,
      tt_measures TYPE STANDARD TABLE OF ty_measure WITH EMPTY KEY.

    CONSTANTS c_runs TYPE i VALUE 20.

    METHODS measure
      IMPORTING iv_query          TYPE string
      RETURNING VALUE(rs_measure) TYPE ty_measure.

    METHODS run_query
      IMPORTING iv_query       TYPE string
      RETURNING VALUE(rv_rows) TYPE i.

ENDCLASS.


CLASS zcl_08_03_dynamic_cache IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 8.03: DYNAMIC CACHE - WHEN TO CACHE A QUERY AND HOW TO MEASURE IT ===' ).
    out->write( 'Dynamic cache: ZDC_08_03_BOOKING_REV on /DMO/BOOKING' ).
    out->write( ' ' ).

    out->write( '--- Step 1: Data volume of the cached table ---' ).
    SELECT FROM /dmo/booking
      FIELDS COUNT(*)
      INTO @DATA(lv_rows).
    out->write( |Rows in /DMO/BOOKING: { lv_rows }| ).
    out->write( ' ' ).

    out->write( '--- Step 2: Result of the query that matches the cache definition ---' ).
    SELECT FROM /dmo/booking
      FIELDS carrier_id,
             currency_code,
             SUM( flight_price ) AS revenue
      GROUP BY carrier_id, currency_code
      ORDER BY carrier_id
      INTO TABLE @DATA(lt_revenue).
    out->write( lt_revenue ).
    out->write( ' ' ).

    out->write( |--- Step 3: Response times over { c_runs } executions ---| ).
    DATA(lt_measures) = VALUE tt_measures( ( measure( `CACHED: carrier + currency` ) )
                                           ( measure( `CACHED + filter on carrier` ) )
                                           ( measure( `NOT CACHED: carrier + connection` ) )
                                           ( measure( `NOT CACHED: detail rows` ) ) ).
    out->write( lt_measures ).
  ENDMETHOD.


  METHOD measure.
    rs_measure-query      = iv_query.
    rs_measure-runs       = c_runs.
    rs_measure-fastest_ms = 999999.
    DATA lv_total_ms TYPE decfloat34.

    DO c_runs TIMES.
      DATA(lv_start) = utclong_current( ).
      rs_measure-result_rows = run_query( iv_query ).
      DATA(lv_ms) = CONV decfloat34( utclong_diff( high = utclong_current( ) low = lv_start ) * 1000 ).
      IF sy-index = 1.
        rs_measure-first_ms = lv_ms.
      ENDIF.
      lv_total_ms += lv_ms.
      rs_measure-fastest_ms = nmin( val1 = rs_measure-fastest_ms val2 = lv_ms ).
    ENDDO.

    rs_measure-average_ms = round( val = lv_total_ms / c_runs dec = 3 ).
    rs_measure-first_ms   = round( val = rs_measure-first_ms dec = 3 ).
    rs_measure-fastest_ms = round( val = rs_measure-fastest_ms dec = 3 ).
  ENDMETHOD.


  METHOD run_query.
    CASE iv_query.
      WHEN `CACHED: carrier + currency`.
        SELECT FROM /dmo/booking
          FIELDS carrier_id, currency_code, SUM( flight_price ) AS revenue
          GROUP BY carrier_id, currency_code
          INTO TABLE @DATA(lt_cached).
        rv_rows = lines( lt_cached ).

      WHEN `CACHED + filter on carrier`.
        SELECT FROM /dmo/booking
          FIELDS carrier_id, currency_code, SUM( flight_price ) AS revenue
          WHERE carrier_id = 'LH'
          GROUP BY carrier_id, currency_code
          INTO TABLE @DATA(lt_cached_filter).
        rv_rows = lines( lt_cached_filter ).

      WHEN `NOT CACHED: carrier + connection`.
        SELECT FROM /dmo/booking
          FIELDS carrier_id, connection_id, currency_code, SUM( flight_price ) AS revenue
          GROUP BY carrier_id, connection_id, currency_code
          INTO TABLE @DATA(lt_not_cached).
        rv_rows = lines( lt_not_cached ).

      WHEN `NOT CACHED: detail rows`.
        SELECT FROM /dmo/booking
          FIELDS carrier_id, currency_code, flight_price
          INTO TABLE @DATA(lt_detail).
        rv_rows = lines( lt_detail ).
    ENDCASE.
  ENDMETHOD.

ENDCLASS.

