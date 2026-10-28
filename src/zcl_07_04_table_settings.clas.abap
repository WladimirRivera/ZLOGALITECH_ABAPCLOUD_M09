CLASS zcl_07_04_table_settings DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_setting,
        table_name           TYPE string,
        delivery_class       TYPE string,
        data_maintenance     TYPE string,
        enhancement_category TYPE string,
      END OF ty_setting,
      tt_settings TYPE STANDARD TABLE OF ty_setting WITH EMPTY KEY,
      tt_config   TYPE STANDARD TABLE OF ztb_07_04_config WITH EMPTY KEY.

    METHODS read_settings
      IMPORTING iv_table          TYPE sxco_dbt_object_name
      RETURNING VALUE(rs_setting) TYPE ty_setting.

ENDCLASS.


CLASS zcl_07_04_table_settings IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 7.04: ENHANCEMENT CATEGORY, DELIVERY CLASS AND DATA MAINTENANCE ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Technical settings read from the ABAP Dictionary ---' ).
    DATA(lt_settings) = VALUE tt_settings( ( read_settings( 'ZTB_07_03_REVIEW' ) )
                                           ( read_settings( 'ZTB_07_04_CONFIG' ) )
                                           ( read_settings( 'ZTB_07_04_LOG' ) )
                                           ( read_settings( '/DMO/FLIGHT' ) ) ).
    out->write( lt_settings ).
    out->write( ' ' ).

    out->write( '--- Example 2: Delivery class C - configuration data (ZTB_07_04_CONFIG) ---' ).
    DATA(lt_config) = VALUE tt_config( ( seat_class = 'E' discount_pct = '0.00'  max_bags = 1 lounge_access = abap_false )
                                       ( seat_class = 'B' discount_pct = '5.00'  max_bags = 2 lounge_access = abap_true )
                                       ( seat_class = 'F' discount_pct = '10.00' max_bags = 3 lounge_access = abap_true ) ).
    MODIFY ztb_07_04_config FROM TABLE @lt_config.
    out->write( |MODIFY ztb_07_04_config: sy-dbcnt = { sy-dbcnt }| ).
    SELECT FROM ztb_07_04_config
      FIELDS seat_class, discount_pct, max_bags, lounge_access
      ORDER BY seat_class
      INTO TABLE @DATA(lt_config_db).
    out->write( lt_config_db ).
    out->write( ' ' ).

    out->write( '--- Example 3: Delivery class L - temporary data (ZTB_07_04_LOG) ---' ).
    TRY.
        GET TIME STAMP FIELD DATA(lv_now).
        DATA(ls_log) = VALUE ztb_07_04_log( log_id     = cl_system_uuid=>create_uuid_x16_static( )
                                            created_at = lv_now
                                            message    = |Configuration loaded: { lines( lt_config ) } seat classes| ).
        INSERT ztb_07_04_log FROM @ls_log.
        out->write( |INSERT ztb_07_04_log: sy-subrc = { sy-subrc }| ).
      CATCH cx_uuid_error INTO DATA(lx_uuid).
        out->write( lx_uuid->get_text( ) ).
    ENDTRY.
    SELECT FROM ztb_07_04_log
      FIELDS COUNT(*)
      INTO @DATA(lv_log_rows).
    out->write( |Rows in ztb_07_04_log: { lv_log_rows }| ).
  ENDMETHOD.


  METHOD read_settings.
    DATA(ls_content) = xco_cp_abap_dictionary=>database_table( iv_table )->content( )->get( ).
    rs_setting = VALUE #( table_name           = iv_table
                          delivery_class       = COND #( WHEN ls_content-delivery_class IS BOUND
                                                         THEN ls_content-delivery_class->value )
                          data_maintenance     = COND #( WHEN ls_content-data_maintenance IS BOUND
                                                         THEN ls_content-data_maintenance->value )
                          enhancement_category = COND #( WHEN ls_content-enhancement_category IS BOUND
                                                         THEN ls_content-enhancement_category->value ) ).
  ENDMETHOD.

ENDCLASS.

