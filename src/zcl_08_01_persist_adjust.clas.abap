CLASS zcl_08_01_persist_adjust DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_field,
        field_name   TYPE string,
        ddic_type    TYPE string,
        abap_type    TYPE string,
        length_chars TYPE i,
      END OF ty_field,
      tt_fields TYPE STANDARD TABLE OF ty_field WITH EMPTY KEY,
      tt_feedback TYPE STANDARD TABLE OF ztb_08_01_feedbk WITH EMPTY KEY.

    CONSTANTS c_table TYPE string VALUE 'ZTB_08_01_FEEDBK'.
    CONSTANTS c_long_comment TYPE string
      VALUE 'Excellent crew, the meal was great and the seat was very comfortable'.

    METHODS describe_table
      RETURNING VALUE(rt_fields) TYPE tt_fields.

ENDCLASS.


CLASS zcl_08_01_persist_adjust IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 8.01: PERSISTENCE ADJUSTMENTS - ALTER, CONVERSION, INDIRECT CHANGES ===' ).
    out->write( ' ' ).

    out->write( |--- Step 1: Current structure of { c_table } (runtime type information) ---| ).
    DATA(lt_fields) = describe_table( ).
    out->write( lt_fields ).
    out->write( ' ' ).

    out->write( '--- Step 2: Reload test data ---' ).
    DELETE FROM ztb_08_01_feedbk.
    out->write( |Deleted rows: { sy-dbcnt }| ).

    SELECT FROM /dmo/customer
      FIELDS customer_id
      ORDER BY customer_id
      INTO TABLE @DATA(lt_customers)
      UP TO 8 ROWS.

    DATA(lt_carriers) = VALUE string_table( ( `LH` ) ( `AA` ) ( `UA` ) ( `SQ` ) ).
    DATA(lt_comments) = VALUE string_table( ( `Good flight` )
                                            ( `Late departure, friendly staff` )
                                            ( c_long_comment )
                                            ( `Lost luggage` ) ).
    GET TIME STAMP FIELD DATA(lv_now).

    DATA lt_feedback TYPE tt_feedback.
    LOOP AT lt_customers INTO DATA(ls_customer).
      DATA(lv_index) = sy-tabix.
      DATA(lv_slot)  = ( lv_index - 1 ) MOD 4 + 1.
      APPEND VALUE #( feedback_id  = lv_index
                      customer_id  = ls_customer-customer_id
                      carrier_id   = lt_carriers[ lv_slot ]
                      comment_text = lt_comments[ lv_slot ]
                      rating       = CONV #( ( lv_index - 1 ) MOD 5 + 1 )
                      legacy_code  = COND #( WHEN lv_index MOD 2 = 0 THEN |OLD-{ lv_index }| )
                      created_at   = lv_now ) TO lt_feedback.
    ENDLOOP.
    INSERT ztb_08_01_feedbk FROM TABLE @lt_feedback.
    out->write( |Inserted rows: { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Step 3: Data currently stored in the table ---' ).
    SELECT FROM ztb_08_01_feedbk
      FIELDS *
      ORDER BY feedback_id
      INTO TABLE @DATA(lt_stored).
    out->write( lt_stored ).
    out->write( ' ' ).

    out->write( '--- Step 4: Truncation check for COMMENT_TEXT ---' ).
    DATA(lv_stored_comment) = VALUE #( lt_stored[ feedback_id = 3 ]-comment_text OPTIONAL ).
    out->write( |Text sent     ({ strlen( c_long_comment ) } chars): { c_long_comment }| ).
    out->write( |Text stored   ({ strlen( lv_stored_comment ) } chars): { lv_stored_comment }| ).
    out->write( |Field length  : { VALUE #( lt_fields[ field_name = `COMMENT_TEXT` ]-length_chars OPTIONAL ) } chars| ).
    out->write( ' ' ).

    out->write( '--- Step 5: Impact analysis before changing the table ---' ).
    SELECT FROM ztb_08_01_feedbk
      FIELDS COUNT(*)
      INTO @DATA(lv_total_rows).
    SELECT FROM ztb_08_01_feedbk
      FIELDS COUNT(*)
      WHERE legacy_code <> @space
      INTO @DATA(lv_legacy_rows).
    SELECT FROM ztb_08_01_feedbk
      FIELDS MAX( length( comment_text ) ) AS max_length
      INTO @DATA(lv_max_length).
    out->write( |Total rows                        : { lv_total_rows }| ).
    out->write( |Rows with data in LEGACY_CODE     : { lv_legacy_rows }| ).
    out->write( |Longest COMMENT_TEXT in use       : { lv_max_length } chars| ).
    out->write( ' ' ).

    out->write( '--- Step 6: Indirect dependency - table field -> data element -> domain ---' ).
    DATA(lo_dtel) = CAST cl_abap_elemdescr( cl_abap_typedescr=>describe_by_name( 'ZDE_08_01_COMMENT' ) ).
    out->write( |ZTB_08_01_FEEDBK-COMMENT_TEXT -> ZDE_08_01_COMMENT -> ZDO_08_01_COMMENT| ).
    out->write( |Length inherited from the domain : { lo_dtel->output_length } chars| ).
  ENDMETHOD.


  METHOD describe_table.
    DATA(lo_struct) = CAST cl_abap_structdescr( cl_abap_typedescr=>describe_by_name( c_table ) ).
    LOOP AT lo_struct->get_components( ) INTO DATA(ls_component).
      DATA(lo_type) = ls_component-type.
      DATA(lv_length) = COND i( WHEN lo_type IS INSTANCE OF cl_abap_elemdescr
                                THEN CAST cl_abap_elemdescr( lo_type )->output_length ).
      APPEND VALUE #( field_name   = ls_component-name
                      ddic_type    = replace( val = lo_type->absolute_name sub = `\TYPE=` with = `` )
                      abap_type    = lo_type->type_kind
                      length_chars = lv_length ) TO rt_fields.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

