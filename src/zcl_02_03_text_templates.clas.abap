*&---------------------------------------------------------------------*
*& ABAP Programacion Estructurada - Class 2
*& Section 4: Text symbols, string templates and built-in functions
*&---------------------------------------------------------------------*
CLASS zcl_02_03_text_templates DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS text_symbols                IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS string_templates_basic      IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS string_templates_formatting IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS builtin_description_funcs   IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS builtin_processing_funcs    IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS builtin_content_funcs       IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_02_03_text_templates IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== SECTION 4: TEXT SYMBOLS, STRING TEMPLATES, BUILT-IN FUNCTIONS ===' ).

    text_symbols( out ).
    string_templates_basic( out ).
    string_templates_formatting( out ).
    builtin_description_funcs( out ).
    builtin_processing_funcs( out ).
    builtin_content_funcs( out ).
  ENDMETHOD.


  METHOD text_symbols.
    out->write( '--- 4.1 Text elements and text symbols ---' ).
    out->write( 'TEXT-001 / TEXT-002 are text symbols maintained in this class''s own' ).
    out->write( 'text pool (Properties > Text Symbols in Eclipse), not hardcoded literals.' ).
    out->write( 'This centralizes text for reuse and translation without touching code.' ).

    out->write( |TEXT-001 -> { TEXT-001 }| ).
    out->write( |TEXT-002 -> { TEXT-002 }| ).

    out->write( 'A classic report would show the same symbol with: WRITE: TEXT-001.' ).
    out->write( 'A message would reuse it too: MESSAGE i001(zmsg_class) WITH TEXT-002.' ).
  ENDMETHOD.


  METHOD string_templates_basic.
    out->write( '--- 4.2 String templates: basic interpolation ---' ).

    DATA: lv_first_name TYPE string VALUE 'John',
          lv_last_name  TYPE string VALUE 'Smith',
          lv_order_qty  TYPE i      VALUE 5.

    DATA(lv_greeting) = |Hello { lv_first_name } { lv_last_name }!|.
    DATA(lv_summary)  = |Order contains { lv_order_qty } unit(s)|.

    out->write( lv_greeting ).
    out->write( lv_summary ).
  ENDMETHOD.


  METHOD string_templates_formatting.
    out->write( '--- 4.2 String templates: formatting options ---' ).

    DATA lv_amount TYPE p LENGTH 8 DECIMALS 2 VALUE '1250.50'.
    DATA(lv_order_qty) = 5.

    DATA(lv_formatted) = |Total: { lv_amount DECIMALS = 2 }|.
    DATA(lv_padded)    = |Code: { lv_order_qty WIDTH = 5 ALIGN = RIGHT PAD = '0' }|.

    out->write( lv_formatted ).
    out->write( lv_padded ).
  ENDMETHOD.


  METHOD builtin_description_funcs.
    out->write( '--- 4.3 Built-in functions: description (inspect without changing) ---' ).

    DATA(lv_greeting) = |Hello World!|.

    DATA(lv_length)   = strlen( lv_greeting ).
    DATA(lv_is_empty) = xsdbool( lv_greeting IS INITIAL ).

    out->write( |strlen( '{ lv_greeting }' )  -> { lv_length }| ).
    out->write( |xsdbool( IS INITIAL )        -> '{ lv_is_empty }'| ).
  ENDMETHOD.


  METHOD builtin_processing_funcs.
    out->write( '--- 4.3 Built-in functions: processing (return a transformed copy) ---' ).

    DATA(lv_greeting) = |  Hello   World!  |.

    DATA(lv_upper)     = to_upper( lv_greeting ).
    DATA(lv_lower)     = to_lower( lv_greeting ).
    DATA(lv_condensed) = condense( lv_greeting ).
    DATA(lv_reversed)  = reverse( condense( lv_greeting ) ).

    out->write( |to_upper( )  -> '{ lv_upper }'| ).
    out->write( |to_lower( )  -> '{ lv_lower }'| ).
    out->write( |condense( ) -> '{ lv_condensed }'| ).
    out->write( |reverse( )  -> '{ lv_reversed }'| ).
  ENDMETHOD.


  METHOD builtin_content_funcs.
    out->write( '--- 4.3 Built-in functions: content (extract/build values) ---' ).

    DATA(lv_greeting) = |Hello World!|.
    DATA(lv_greeting2) = |Hello World!|.

    DATA(lv_piece) = substring( val = lv_greeting off = 0 len = 5 ).
    DATA(lv_count) = count( val = lv_greeting sub = 'l' ).
    lv_greeting2 = lv_greeting2+0(5).
    out->write( |substring( off = 0 len = 5 ) -> '{ lv_piece }'| ).
    out->write( |count( sub = 'l' )            -> { lv_count }| ).
    out->write( |Substring2: { lv_greeting2 }| ).

    out->write( 'Functions nest freely, even inside a template:' ).
    out->write( |Name: { to_upper( 'john' ) }| ).
  ENDMETHOD.

ENDCLASS.
