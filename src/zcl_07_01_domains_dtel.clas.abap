CLASS zcl_07_01_domains_dtel DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_fixed_value,
        domain      TYPE string,
        lower_limit TYPE string,
        upper_limit TYPE string,
        description TYPE string,
      END OF ty_fixed_value,
      tt_fixed_values TYPE STANDARD TABLE OF ty_fixed_value WITH EMPTY KEY,

      BEGIN OF ty_label,
        data_element TYPE string,
        short_label  TYPE string,
        medium_label TYPE string,
        long_label   TYPE string,
        heading      TYPE string,
      END OF ty_label,
      tt_labels TYPE STANDARD TABLE OF ty_label WITH EMPTY KEY,

      BEGIN OF ty_check,
        domain      TYPE string,
        input_value TYPE string,
        is_valid    TYPE abap_bool,
      END OF ty_check,
      tt_checks TYPE STANDARD TABLE OF ty_check WITH EMPTY KEY.

    METHODS get_fixed_values
      IMPORTING iv_domain              TYPE sxco_ad_object_name
      RETURNING VALUE(rt_fixed_values) TYPE tt_fixed_values.

    METHODS get_labels
      IMPORTING iv_data_element TYPE sxco_ad_object_name
      RETURNING VALUE(rs_label) TYPE ty_label.

    METHODS is_valid
      IMPORTING iv_domain       TYPE sxco_ad_object_name
                iv_value        TYPE string
      RETURNING VALUE(rv_valid) TYPE abap_bool.

ENDCLASS.


CLASS zcl_07_01_domains_dtel IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 7.01: DOMAINS, FIXED VALUES AND DATA ELEMENTS ===' ).
    out->write( ' ' ).

    out->write( '--- Example 1: Domain with single fixed values (ZDO_07_01_SEAT_CLASS) ---' ).
    out->write( get_fixed_values( 'ZDO_07_01_SEAT_CLASS' ) ).
    out->write( ' ' ).

    out->write( '--- Example 2: Domain with an interval (ZDO_07_01_RATING) ---' ).
    out->write( get_fixed_values( 'ZDO_07_01_RATING' ) ).
    out->write( ' ' ).

    out->write( '--- Example 3: Validating input against the domain ---' ).
    DATA(lt_checks) = VALUE tt_checks( ( domain = `ZDO_07_01_SEAT_CLASS` input_value = `B` )
                                       ( domain = `ZDO_07_01_SEAT_CLASS` input_value = `X` )
                                       ( domain = `ZDO_07_01_RATING`     input_value = `4` )
                                       ( domain = `ZDO_07_01_RATING`     input_value = `7` ) ).
    LOOP AT lt_checks ASSIGNING FIELD-SYMBOL(<ls_check>).
      <ls_check>-is_valid = is_valid( iv_domain = CONV #( <ls_check>-domain )
                                      iv_value  = <ls_check>-input_value ).
    ENDLOOP.
    out->write( lt_checks ).
    out->write( ' ' ).

    out->write( '--- Example 4: Semantic role - field labels of each data element ---' ).
    DATA(lt_labels) = VALUE tt_labels( ( get_labels( 'ZDE_07_01_SEAT_CLASS' ) )
                                       ( get_labels( 'ZDE_07_01_RATING' ) )
                                       ( get_labels( 'ZDE_07_01_DISCOUNT_PCT' ) ) ).
    out->write( lt_labels ).
    out->write( ' ' ).

    out->write( '--- Example 5: Technical type - domain based vs predefined type ---' ).
    DATA lv_seat_class TYPE zde_07_01_seat_class   VALUE 'F'.
    DATA lv_rating     TYPE zde_07_01_rating       VALUE '5'.
    DATA lv_discount   TYPE zde_07_01_discount_pct VALUE '12.50'.
    DATA(lo_seat_type)     = cl_abap_typedescr=>describe_by_data( lv_seat_class ).
    DATA(lo_rating_type)   = cl_abap_typedescr=>describe_by_data( lv_rating ).
    DATA(lo_discount_type) = cl_abap_typedescr=>describe_by_data( lv_discount ).
    out->write( |ZDE_07_01_SEAT_CLASS   = { lv_seat_class }  type kind { lo_seat_type->type_kind }, length { lo_seat_type->length }| ).
    out->write( |ZDE_07_01_RATING       = { lv_rating }  type kind { lo_rating_type->type_kind }, length { lo_rating_type->length }| ).
    out->write( |ZDE_07_01_DISCOUNT_PCT = { lv_discount }  type kind { lo_discount_type->type_kind }, decimals { lo_discount_type->decimals }| ).
  ENDMETHOD.


  METHOD get_fixed_values.
    LOOP AT xco_cp_abap_dictionary=>domain( iv_domain )->fixed_values->all->get( ) INTO DATA(lo_fixed_value).
      DATA(ls_content) = lo_fixed_value->content( )->get( ).
      APPEND VALUE #( domain      = iv_domain
                      lower_limit = lo_fixed_value->lower_limit
                      upper_limit = ls_content-upper_limit
                      description = ls_content-description ) TO rt_fixed_values.
    ENDLOOP.
  ENDMETHOD.


  METHOD get_labels.
    DATA(ls_content) = xco_cp_abap_dictionary=>data_element( iv_data_element )->content( )->get( ).
    rs_label = VALUE #( data_element = iv_data_element
                        short_label  = ls_content-short_field_label-text
                        medium_label = ls_content-medium_field_label-text
                        long_label   = ls_content-long_field_label-text
                        heading      = ls_content-heading_field_label-text ).
  ENDMETHOD.


  METHOD is_valid.
    LOOP AT get_fixed_values( iv_domain ) INTO DATA(ls_fixed_value).
      IF ls_fixed_value-upper_limit IS INITIAL.
        IF iv_value = ls_fixed_value-lower_limit.
          rv_valid = abap_true.
          RETURN.
        ENDIF.
      ELSEIF iv_value BETWEEN ls_fixed_value-lower_limit AND ls_fixed_value-upper_limit.
        rv_valid = abap_true.
        RETURN.
      ENDIF.
    ENDLOOP.

*    data lv_type TYPE ZDe_07_01_SEAT_CLASS.
*    data lt_type TYPE ZTT_07_02_BOOKINGS.
  ENDMETHOD.

ENDCLASS.

