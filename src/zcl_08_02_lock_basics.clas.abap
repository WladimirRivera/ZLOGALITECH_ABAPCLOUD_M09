CLASS zcl_08_02_lock_basics DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS c_lock_object TYPE if_abap_lock_object=>tv_name VALUE '/DMO/ETRAVEL'.
    CONSTANTS c_own_lock_object TYPE if_abap_lock_object=>tv_name VALUE 'EZ_08_02_FEEDBK'.

ENDCLASS.


CLASS zcl_08_02_lock_basics IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 8.02: LOCK OBJECTS - REQUEST, MODES AND RELEASE ===' ).
    out->write( ' ' ).

    SELECT FROM /dmo/travel
      FIELDS MIN( travel_id )
      INTO @DATA(lv_travel_id).
    DATA(lt_parameter) = VALUE if_abap_lock_object=>tt_parameter( ( name = 'TRAVEL_ID' value = REF #( lv_travel_id ) ) ).

    out->write( |--- Step 1: Get the lock object { c_lock_object } ---| ).
    TRY.
        DATA(lo_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = c_lock_object ).
        out->write( |Lock object instance created. Lock argument: TRAVEL_ID = { lv_travel_id }| ).
      CATCH cx_abap_lock_failure INTO DATA(lx_failure).
        out->write( lx_failure->get_text( ) ).
        RETURN.
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 2: Request a write lock (mode E) ---' ).
    TRY.
        lo_lock->enqueue( it_parameter = lt_parameter ).
        out->write( 'Result: lock granted' ).
      CATCH cx_abap_foreign_lock INTO DATA(lx_foreign).
        out->write( |Result: locked by user { lx_foreign->user_name }| ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 3: Request the same write lock again (cumulative) ---' ).
    TRY.
        lo_lock->enqueue( it_parameter = lt_parameter ).
        out->write( 'Result: lock granted' ).
      CATCH cx_abap_foreign_lock INTO lx_foreign.
        out->write( |Result: locked by user { lx_foreign->user_name }| ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 4: Request an exclusive non-cumulative lock (mode X) on the same travel ---' ).
    DATA(lt_mode_x) = VALUE if_abap_lock_object=>tt_table_mode( ( table_name = '/DMO/TRAVEL'
                                                                  mode       = if_abap_lock_object=>cs_mode-exclusive_lock ) ).
    TRY.
        lo_lock->enqueue( it_table_mode = lt_mode_x
                          it_parameter  = lt_parameter ).
        out->write( 'Result: lock granted' ).
      CATCH cx_abap_foreign_lock INTO lx_foreign.
        out->write( |Result: locked by user { lx_foreign->user_name }| ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 5: Release the write locks ---' ).
    TRY.
        lo_lock->dequeue( it_parameter = lt_parameter ).
        lo_lock->dequeue( it_parameter = lt_parameter ).
        out->write( 'Result: write locks released' ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 6: Request the exclusive lock (mode X) again ---' ).
    TRY.
        lo_lock->enqueue( it_table_mode = lt_mode_x
                          it_parameter  = lt_parameter ).
        out->write( 'Result: lock granted' ).
        lo_lock->dequeue( it_table_mode = lt_mode_x
                          it_parameter  = lt_parameter ).
        out->write( 'Result: lock released' ).
      CATCH cx_abap_foreign_lock INTO lx_foreign.
        out->write( |Result: locked by user { lx_foreign->user_name }| ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
    ENDTRY.
    out->write( ' ' ).

    out->write( |--- Step 7: Own lock object { c_own_lock_object } on ZTB_08_01_FEEDBK ---| ).
    DATA(lv_feedback_id) = CONV ztb_08_01_feedbk-feedback_id( 1 ).
    TRY.
        DATA(lo_own_lock) = cl_abap_lock_object_factory=>get_instance( iv_name = c_own_lock_object ).
        lo_own_lock->enqueue( it_parameter = VALUE #( ( name = 'FEEDBACK_ID' value = REF #( lv_feedback_id ) ) ) ).
        out->write( |Result: lock granted for FEEDBACK_ID = { lv_feedback_id }| ).
        lo_own_lock->dequeue( it_parameter = VALUE #( ( name = 'FEEDBACK_ID' value = REF #( lv_feedback_id ) ) ) ).
        out->write( 'Result: lock released' ).
      CATCH cx_abap_foreign_lock INTO lx_foreign.
        out->write( |Result: locked by user { lx_foreign->user_name }| ).
      CATCH cx_abap_lock_failure INTO lx_failure.
        out->write( |Result: { lx_failure->get_text( ) }| ).
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 8: Release every lock of this session ---' ).
    cl_abap_lock_object_factory=>dequeue_all( ).
    out->write( 'Result: DEQUEUE_ALL executed' ).
  ENDMETHOD.

ENDCLASS.

