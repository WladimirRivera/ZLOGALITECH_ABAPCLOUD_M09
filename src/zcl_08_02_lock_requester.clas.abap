CLASS zcl_08_02_lock_requester DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS c_lock_object TYPE if_abap_lock_object=>tv_name VALUE '/DMO/ETRAVEL'.

ENDCLASS.


CLASS zcl_08_02_lock_requester IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 8.02: MULTI-USER SIMULATION - USER B (LOCK REQUESTER) ===' ).
    out->write( ' ' ).

    SELECT FROM /dmo/travel
      FIELDS MIN( travel_id )
      INTO @DATA(lv_travel_id).
    DATA(lt_parameter) = VALUE if_abap_lock_object=>tt_parameter( ( name = 'TRAVEL_ID' value = REF #( lv_travel_id ) ) ).

    TRY.
        DATA(lo_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = c_lock_object ).
      CATCH cx_abap_lock_failure INTO DATA(lx_failure).
        out->write( lx_failure->get_text( ) ).
        RETURN.
    ENDTRY.

    out->write( |--- Step 1: Try to lock travel { lv_travel_id } without waiting ---| ).
    out->write( |Requested at: { utclong_current( ) TIMESTAMP = ISO }| ).
    TRY.
        lo_lock->enqueue( it_parameter = lt_parameter ).
        out->write( 'Result: lock granted' ).
        lo_lock->dequeue( it_parameter = lt_parameter ).
        out->write( 'Result: lock released' ).
        RETURN.
      CATCH cx_abap_foreign_lock INTO DATA(lx_foreign).
        out->write( |Result: locked by user { lx_foreign->user_name }| ).
        out->write( |Message: { lx_foreign->get_text( ) }| ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
        RETURN.
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 2: Try again with automatic retries (_wait = X) ---' ).
    DATA(lv_start) = utclong_current( ).
    TRY.
        lo_lock->enqueue( it_parameter = lt_parameter
                          _wait        = if_abap_lock_object=>cs_wait-yes ).
        out->write( |Result: lock granted after { utclong_diff( high = utclong_current( ) low = lv_start ) DECIMALS = 1 } seconds| ).
        lo_lock->dequeue( it_parameter = lt_parameter ).
        out->write( 'Result: lock released' ).
      CATCH cx_abap_foreign_lock INTO lx_foreign.
        out->write( |Result: still locked by user { lx_foreign->user_name } after { utclong_diff( high = utclong_current( ) low = lv_start ) DECIMALS = 1 } seconds| ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
    ENDTRY.
  ENDMETHOD.

ENDCLASS.

