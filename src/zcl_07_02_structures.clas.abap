CLASS zcl_07_02_structures DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES tt_bookings_with_keys TYPE STANDARD TABLE OF zst_07_02_booking
      WITH NON-UNIQUE KEY travel_id booking_id
      WITH NON-UNIQUE SORTED KEY by_flight  COMPONENTS carrier_id connection_id flight_date
      WITH UNIQUE HASHED KEY     by_booking COMPONENTS travel_id booking_id.

    TYPES:
      BEGIN OF ty_component,
        name      TYPE string,
        type_kind TYPE string,
        is_include TYPE abap_bool,
      END OF ty_component,
      tt_components TYPE STANDARD TABLE OF ty_component WITH EMPTY KEY.

    METHODS read_customer
      IMPORTING iv_customer_id     TYPE /dmo/customer_id
      RETURNING VALUE(rs_customer) TYPE zst_07_02_customer.

    METHODS read_bookings
      IMPORTING iv_customer_id     TYPE /dmo/customer_id
      RETURNING VALUE(rt_bookings) TYPE ztt_07_02_bookings.

    METHODS describe
      IMPORTING iv_structure         TYPE string
      RETURNING VALUE(rt_components) TYPE tt_components.

ENDCLASS.


CLASS zcl_07_02_structures IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 7.02: GLOBAL STRUCTURES, INCLUDES, TABLE TYPES AND DEEP STRUCTURES ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Global structure ZST_07_02_ADDRESS ---' ).
    DATA(ls_customer) = read_customer( '000253' ).
    DATA(ls_address) = CORRESPONDING zst_07_02_address( ls_customer ).
    out->write( ls_address ).
    out->write( ' ' ).

    out->write( '--- Example 2: Structure with INCLUDE (ZST_07_02_CUSTOMER) ---' ).
    out->write( ls_customer ).
    out->write( |ls_customer-city = { ls_customer-city }| ).
    out->write( describe( `ZST_07_02_CUSTOMER` ) ).
    out->write( ' ' ).

    out->write( '--- Example 3: Table type ZTT_07_02_BOOKINGS ---' ).
    DATA(lt_bookings) = read_bookings( '000253' ).
    out->write( lt_bookings ).
    out->write( ' ' ).

    out->write( '--- Example 4: Same row type with secondary keys ---' ).
    DATA(lt_keyed) = CORRESPONDING tt_bookings_with_keys( lt_bookings ).
    DATA(ls_first) = VALUE #( lt_bookings[ 1 ] OPTIONAL ).
    DATA(ls_by_booking) = VALUE #( lt_keyed[ KEY by_booking travel_id  = ls_first-travel_id
                                                            booking_id = ls_first-booking_id ] OPTIONAL ).
    out->write( |KEY by_booking -> { ls_by_booking-travel_id }/{ ls_by_booking-booking_id } { ls_by_booking-carrier_id } { ls_by_booking-connection_id }| ).
    LOOP AT lt_keyed INTO DATA(ls_flight_row) USING KEY by_flight WHERE carrier_id = ls_first-carrier_id.
      out->write( |KEY by_flight -> { ls_flight_row-carrier_id } { ls_flight_row-connection_id } { ls_flight_row-flight_date }| ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Example 5: Deep structure ZST_07_02_CUSTOMER_DEEP ---' ).
    DATA(ls_deep) = VALUE zst_07_02_customer_deep( customer = ls_customer
                                                   bookings = lt_bookings
                                                   notes    = |Frequent flyer since { ls_first-flight_date DATE = ISO }| ).
    out->write( |customer-last_name = { ls_deep-customer-last_name }| ).
    out->write( |customer-city      = { ls_deep-customer-city }| ).
    out->write( |lines( bookings )  = { lines( ls_deep-bookings ) }| ).
    out->write( |bookings[ 1 ]      = { VALUE #( ls_deep-bookings[ 1 ]-carrier_id OPTIONAL ) } { VALUE #( ls_deep-bookings[ 1 ]-connection_id OPTIONAL ) }| ).
    out->write( |notes              = { ls_deep-notes }| ).
    out->write( ' ' ).

    out->write( '--- Example 6: Components of the deep structure ---' ).
    out->write( describe( `ZST_07_02_CUSTOMER_DEEP` ) ).
  ENDMETHOD.


  METHOD read_customer.
    SELECT SINGLE FROM /dmo/customer
      FIELDS customer_id, first_name, last_name, street, postal_code, city,
             country_code AS country
      WHERE customer_id = @iv_customer_id
      INTO CORRESPONDING FIELDS OF @rs_customer.
  ENDMETHOD.


  METHOD read_bookings.
    SELECT FROM /dmo/booking
      FIELDS travel_id, booking_id, carrier_id, connection_id, flight_date,
             flight_price, currency_code,
             CASE WHEN flight_price >= 3000 THEN 'F'
                  WHEN flight_price >= 1000 THEN 'B'
                  ELSE 'E' END AS seat_class
      WHERE customer_id = @iv_customer_id
      ORDER BY flight_date
      INTO CORRESPONDING FIELDS OF TABLE @rt_bookings.
  ENDMETHOD.


  METHOD describe.
    DATA(lo_structure) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( iv_structure ) ).
    LOOP AT lo_structure->get_components( ) INTO DATA(ls_component).
      APPEND VALUE #( name       = ls_component-name
                      type_kind  = ls_component-type->type_kind
                      is_include = ls_component-as_include ) TO rt_components.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

