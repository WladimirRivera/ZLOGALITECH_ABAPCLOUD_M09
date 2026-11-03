CLASS zcl_08_02_lock_holder DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS c_lock_object TYPE if_abap_lock_object=>tv_name VALUE '/DMO/ETRAVEL'.
    CONSTANTS c_hold_seconds TYPE i VALUE 60.

ENDCLASS.


CLASS zcl_08_02_lock_holder IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 8.02: MULTI-USER SIMULATION - USER A (LOCK HOLDER) ===' ).
    out->write( ' ' ).

    SELECT FROM /dmo/travel
      FIELDS MIN( travel_id )
      INTO @DATA(lv_travel_id).
    DATA(lt_parameter) = VALUE if_abap_lock_object=>tt_parameter( ( name = 'TRAVEL_ID' value = REF #( lv_travel_id ) ) ).

    out->write( '--- Step 1: Lock the travel ---' ).
    TRY.
        DATA(lo_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = c_lock_object ).
        lo_lock->enqueue( it_parameter = lt_parameter ).
      CATCH cx_abap_foreign_lock INTO DATA(lx_foreign).
        out->write( |Travel { lv_travel_id } is already locked by user { lx_foreign->user_name }| ).
        RETURN.
      CATCH cx_abap_lock_failure INTO DATA(lx_failure).
        out->write( lx_failure->get_text( ) ).
        RETURN.
    ENDTRY.
    out->write( |Travel { lv_travel_id } locked by { cl_abap_context_info=>get_user_technical_name( ) }| ).
    out->write( |Locked at : { utclong_current( ) TIMESTAMP = ISO }| ).
    out->write( ' ' ).

    out->write( |--- Step 2: Hold the lock for { c_hold_seconds } seconds ---| ).
    WAIT UP TO c_hold_seconds SECONDS.
    out->write( ' ' ).

    out->write( '--- Step 3: Release the lock ---' ).
    TRY.
        lo_lock->dequeue( it_parameter = lt_parameter ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( lx_failure->get_text( ) ).
    ENDTRY.
    out->write( |Released at: { utclong_current( ) TIMESTAMP = ISO }| ).
  ENDMETHOD.

ENDCLASS.

