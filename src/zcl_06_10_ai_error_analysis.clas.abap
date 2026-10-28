CLASS zcl_06_10_ai_error_analysis DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    CONSTANTS c_currency        TYPE /dmo/currency_code VALUE 'EUR'.
    CONSTANTS c_fee_per_booking TYPE /dmo/flight_price  VALUE '25.00'.
    CONSTANTS c_handling_fee    TYPE /dmo/flight_price  VALUE '10.00'.

    TYPES:
      BEGIN OF ty_error_context,
        exception_class TYPE string,
        message         TYPE string,
        include_name    TYPE string,
        source_line     TYPE i,
        method_name     TYPE string,
        input_data      TYPE string,
        expected        TYPE string,
      END OF ty_error_context,

      BEGIN OF ty_average_result,
        customer_id  TYPE /dmo/customer_id,
        bookings     TYPE i,
        average_cost TYPE decfloat34,
        status       TYPE string,
      END OF ty_average_result,
      tt_average_results TYPE STANDARD TABLE OF ty_average_result WITH EMPTY KEY.

    METHODS average_cost_buggy
      IMPORTING iv_customer_id    TYPE /dmo/customer_id
      RETURNING VALUE(rv_average) TYPE decfloat34.

    METHODS average_cost_fixed
      IMPORTING iv_customer_id   TYPE /dmo/customer_id
      RETURNING VALUE(rs_result) TYPE ty_average_result.

    METHODS find_customer_without_bookings
      RETURNING VALUE(rv_customer_id) TYPE /dmo/customer_id.

    METHODS find_customer_with_bookings
      RETURNING VALUE(rv_customer_id) TYPE /dmo/customer_id.

    METHODS collect_context
      IMPORTING ix_error          TYPE REF TO cx_root
                iv_method         TYPE string
                iv_input          TYPE string
                iv_expected       TYPE string
      RETURNING VALUE(rs_context) TYPE ty_error_context.

    METHODS build_ai_prompt
      IMPORTING is_context      TYPE ty_error_context
      RETURNING VALUE(rt_lines) TYPE string_table.

ENDCLASS.


CLASS zcl_06_10_ai_error_analysis IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 6.10: AI-ASSISTED ANALYSIS - INTERPRET AN ERROR AND PROPOSE A FIX ===' ).
    out->write( ' ' ).

    DATA(lv_customer_without) = find_customer_without_bookings( ).
    DATA(lv_customer_with)    = find_customer_with_bookings( ).

    out->write( '--- Step 1: Reproduce the error ---' ).
    DATA ls_context TYPE ty_error_context.
    TRY.
        DATA(lv_average) = average_cost_buggy( lv_customer_without ).
        out->write( |Average cost: { lv_average }| ).
      CATCH cx_root INTO DATA(lx_error).
        ls_context = collect_context(
          ix_error    = lx_error
          iv_method   = `AVERAGE_COST_BUGGY`
          iv_input    = |customer_id = { lv_customer_without }, currency = { c_currency }, fee per booking = { c_fee_per_booking }, handling fee = { c_handling_fee }|
          iv_expected = `Average cost per booking, or a clear result when the customer has no bookings` ).
        out->write( |{ ls_context-exception_class }: { ls_context-message }| ).
    ENDTRY.
    out->write( ' ' ).

    out->write( '--- Step 2: Collect the context the AI needs ---' ).
    out->write( data = ls_context name = 'Error context' ).
    out->write( ' ' ).

    out->write( '--- Step 3: Prompt ready to paste into the AI assistant ---' ).
    LOOP AT build_ai_prompt( ls_context ) INTO DATA(lv_prompt_line).
      out->write( lv_prompt_line ).
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Step 4: Validate the AI answer before applying it ---' ).
    out->write( ' ' ).

    out->write( '--- Step 5: Run the corrected method with both inputs ---' ).
    DATA(lt_results) = VALUE tt_average_results( ( average_cost_fixed( lv_customer_without ) )
                                                 ( average_cost_fixed( lv_customer_with ) ) ).
    out->write( lt_results ).
  ENDMETHOD.


  METHOD average_cost_buggy.
    SELECT FROM /dmo/booking
      FIELDS SUM( flight_price ) AS total_price,
             COUNT(*)            AS bookings
      WHERE customer_id   = @iv_customer_id
        AND currency_code = @c_currency
      INTO ( @DATA(lv_total_price), @DATA(lv_bookings) ).

    rv_average = ( lv_total_price + c_fee_per_booking * lv_bookings + c_handling_fee ) / lv_bookings.
  ENDMETHOD.


  METHOD average_cost_fixed.
    SELECT FROM /dmo/booking
      FIELDS SUM( flight_price ) AS total_price,
             COUNT(*)            AS bookings
      WHERE customer_id   = @iv_customer_id
        AND currency_code = @c_currency
      INTO ( @DATA(lv_total_price), @DATA(lv_bookings) ).

    rs_result-customer_id = iv_customer_id.
    rs_result-bookings    = lv_bookings.

    IF lv_bookings = 0.
      rs_result-status = |No { c_currency } bookings - average not calculated|.
      RETURN.
    ENDIF.

    rs_result-average_cost = ( lv_total_price + c_fee_per_booking * lv_bookings + c_handling_fee ) / lv_bookings.
    rs_result-status       = `OK`.
  ENDMETHOD.


  METHOD find_customer_without_bookings.
    SELECT FROM /dmo/customer AS customer
      FIELDS customer~customer_id
      WHERE NOT EXISTS ( SELECT booking_id FROM /dmo/booking
                           WHERE customer_id   = customer~customer_id
                             AND currency_code = @c_currency )
      ORDER BY customer~customer_id
      INTO TABLE @DATA(lt_customers)
      UP TO 1 ROWS.

    rv_customer_id = VALUE #( lt_customers[ 1 ]-customer_id DEFAULT '999999' ).
  ENDMETHOD.


  METHOD find_customer_with_bookings.
    SELECT FROM /dmo/booking
      FIELDS customer_id
      WHERE currency_code = @c_currency
      ORDER BY customer_id
      INTO TABLE @DATA(lt_customers)
      UP TO 1 ROWS.

    rv_customer_id = VALUE #( lt_customers[ 1 ]-customer_id OPTIONAL ).
  ENDMETHOD.


  METHOD collect_context.
    ix_error->get_source_position( IMPORTING include_name = DATA(lv_include)
                                             source_line  = DATA(lv_line) ).

    rs_context = VALUE #( exception_class = cl_abap_typedescr=>describe_by_object_ref( ix_error )->get_relative_name( )
                          message         = ix_error->get_text( )
                          include_name    = lv_include
                          source_line     = lv_line
                          method_name     = iv_method
                          input_data      = iv_input
                          expected        = iv_expected ).
  ENDMETHOD.


  METHOD build_ai_prompt.
    rt_lines = VALUE #(
      ( `You are a senior ABAP Cloud developer. Analyse this runtime error and propose a fix.` )
      ( |Error     : { is_context-exception_class } - { is_context-message }| )
      ( |Position  : method { is_context-method_name }, { is_context-include_name } line { is_context-source_line }| )
      ( |Input     : { is_context-input_data }| )
      ( |Expected  : { is_context-expected }| )
      ( `Context   : ABAP Cloud (BTP ABAP Environment), data read from /DMO/BOOKING.` )
      ( |Attachment: paste the source of method { is_context-method_name } copied from ADT.| )
      ( `Answer with: 1) root cause  2) corrected code  3) how to test the fix.` )
      ( `Privacy   : remove names, e-mails or any personal data before sending the prompt.` ) ).
  ENDMETHOD.

ENDCLASS.

