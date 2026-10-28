CLASS zcl_05_01_expr_constructors DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .
  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .
  PROTECTED SECTION.
  PRIVATE SECTION.
ENDCLASS.

CLASS zcl_05_01_expr_constructors IMPLEMENTATION.
  METHOD if_oo_adt_classrun~main.
*********************Value************************************************
*    TYPES: BEGIN OF ty_students,
*             name TYPE string,
*           END OF ty_students.
*
*    DATA: lt_msg  TYPE STANDARD TABLE OF ty_students,
**          ls_msg LIKE LINE OF lt_msg.
*          ls_msg2 TYPE ty_students.
*
*    lt_msg = VALUE #( ( name = 'Jose' )
*                      ( name = 'Wladimir' ) ).
*
**    ls_msg2-name = 'Jose'.
**    ls_msg2-name = 'Wladimir'.
**    APPEND ls_msg2 to lt_msg.
*
*    ls_msg2 = VALUE #( name = 'Wladimir1' ).
**    APPEND ls_msg2 to lt_msg.
*
**    out->write( data = lt_msg name = 'Value' ).
*    out->write( data = lt_msg ).
*
*
*    DATA(ls_msg) = VALUE ty_students( name = 'Jose1'   ).
*
*    out->write( data = ls_msg ).
*
*    DATA: BEGIN OF ls_emp_data,
*            emp_name TYPE string,
*            BEGIN OF address,
*              street    TYPE string,
*              lv_number TYPE string,
*            END OF address,
*          END OF ls_emp_data.
*
*    TYPES: BEGIN OF ls_emp_data2,
*             emp_name TYPE string,
*             BEGIN OF address,
*               street    TYPE string,
*               lv_number TYPE string,
*             END OF address,
*           END OF ls_emp_data2.
*
*    DATA ls_emp_data2 TYPE ls_emp_data2.
*
*    ls_emp_data2 = VALUE #( emp_name = 'Wladimir4'
*                           address  = VALUE #( street = 'Street CA'
*                                               lv_number = 123  )
*).
*
*    out->write( ls_emp_data2 ).
*
*    SELECT FROM /dmo/flight
*        FIELDS *
*        INTO TABLE @DATA(lt_flights_all).
**        UP TO 10 ROWS.
*
*    DATA lt_table_2 TYPE STANDARD TABLE OF /dmo/flight.
*
*    lt_table_2 = VALUE #( FOR ls_table IN lt_flights_all
**lt_table = VALUE #( FOR i = 1 UNTIL i > 3
*                         WHERE ( carrier_id EQ 'AA' )
*                      ( carrier_id = ls_table-carrier_id
*                        connection_id = ls_table-connection_id
*                        flight_date = ls_table-flight_date )  ).
*
*    out->write( lt_table_2 ).
**********************Corresponding*************************************************
*    TYPES: BEGIN OF ty_old,
*             name TYPE string,
*             age  TYPE i,
*           END OF ty_old.
*
*    TYPES: BEGIN OF ty_new,
*             name    TYPE string,
*             age     TYPE i,
*             address TYPE string,
*           END OF ty_new.
*
*    DATA: ls_old_data TYPE ty_old.
*
*    ls_old_data = VALUE #( name = 'Alice11' age = 25 ).
*
*    DATA(ls_new_data) = CORRESPONDING ty_new( ls_old_data ).
*
*    out->write( ls_old_data ).
*
*    out->write( ls_new_data ).
*
*    out->write( cl_abap_char_utilities=>newline ).
*
*    DATA: lt_old_data   TYPE STANDARD TABLE OF ty_old,
*          lt_exept_data TYPE STANDARD TABLE OF ty_old,
*          lt_new_data   TYPE SORTED TABLE OF ty_new WITH UNIQUE KEY name.
*
*    lt_old_data = VALUE #(  ( name = 'Alice' age = 25 )
*                            ( name = 'Alice' age = 25 )
*                            ( name = 'Alice' age = 25 )
*                            ( name = 'Wladimir' age = 25 ) ).
*
*    lt_new_data = CORRESPONDING #( lt_old_data DISCARDING DUPLICATES ).
**    lt_new_data = CORRESPONDING #( lt_old_data  ).
*    out->write( lt_new_data ).
*
*    lt_exept_data = CORRESPONDING #( lt_old_data EXCEPT age ).
*    out->write( lt_exept_data ).
*
**************************Ref********************************************
*    DATA: lv_lv_num     TYPE i,
*          lr_ref_lv_num TYPE REF TO i.
*
*    lv_lv_num = 200.
*
*    lr_ref_lv_num = REF #( lv_lv_num ). " Crear una referencia al valor de lv_num
*
*    out->write( lr_ref_lv_num->* ). " Acceder al valor referenciado
*    lr_ref_lv_num->* = 100.
**    lv_lv_num = 100.
*    out->write( lv_lv_num ). " Acceder al valor referenciado
*
******************REDUCE****************************************************
*    DATA: lt_lv_numbers TYPE TABLE OF i,
*          lv_sum        TYPE i.
*
*    lt_lv_numbers = VALUE #( ( 1 ) ( 2 ) ( 3 ) ).
*
*    lv_sum = REDUCE #( INIT x = 0
*                    FOR n IN lt_lv_numbers
*                    NEXT x = x + n ).
*
*    out->write( lv_sum ).
*
*    out->write( cl_abap_char_utilities=>newline ).
**
**************************CONV********************************************
*    DATA: lv_text TYPE string,
*          lv_num  TYPE p LENGTH 5 DECIMALS 2 VALUE '3.4'.
*
**    lv_num = 100.
*
*    lv_text = CONV string( lv_num ).
*
*    out->write( lv_text ).
***************************NEW********************************************
*    DATA: lo_class1 TYPE REF TO zcl_05_09_new_example.
*    CREATE OBJECT lo_class1.
*
*    DATA(lo_class2) = NEW zcl_05_09_new_example( ).
*
*    DATA: lo_class3 TYPE REF TO zcl_05_09_new_example.
*
*    lo_class3 = NEW #( ).
*
*    out->write( lo_class1->print_value( )  ).
*    out->write( lo_class2->print_value( )  ).
*    out->write( lo_class3->print_value( )  ).
***************************Cast*********************************************
*    TYPES: BEGIN OF t_struct,
*             col1 TYPE i,
*             col2 TYPE i,
*           END OF t_struct.
*
*    DATA: lo_data TYPE REF TO data,
*          ls_int  TYPE t_struct.
*
*
*    lo_data = NEW t_struct( ).
*
*    ls_int = CAST t_struct( lo_data )->*.
*    ls_int-col1 = CAST t_struct( lo_data )->col1.
*
*    out->write( ls_int ).
*
*    out->write( cl_abap_char_utilities=>newline ).
*
*    ls_int = VALUE #( col1 = 4
*                      col2 = 6 ).
*
*    CAST t_struct( lo_data )->* = ls_int.
*
*    out->write( ls_int ).

**********************Exact***********************************************
*
*    DATA: lv_int_value  TYPE i VALUE 327678,
*          lv_int2_value TYPE int2.
*    TRY.
**        lv_int2_value = EXACT int2( lv_int_value ).
**        lv_int2_value = EXACT #( lv_int_value ).
**        lv_int2_value = lv_int_value.
*        out->write( data = lv_int2_value name = 'Converted value:' ).
*      CATCH cx_sy_conversion_error INTO DATA(lx_error).
*        out->write( data = lx_error->get_text( ) name = 'Error' ).
*    ENDTRY.
*
************************Filter**********************************************

    DATA: lt_flights_all2  TYPE STANDARD TABLE OF /dmo/flight,
          lt_flights_final1 TYPE STANDARD TABLE OF /dmo/flight,
          "Filter table
          lt_filter        TYPE SORTED TABLE OF /dmo/flight-carrier_id WITH UNIQUE KEY table_line.

    SELECT FROM /dmo/flight
        FIELDS *
        INTO TABLE @lt_flights_all2.

    "Filter values
    lt_filter = VALUE #( ( 'AA ' ) ( 'LH ' ) ( 'UA ' ) ).
    lt_flights_final1 =        FILTER #( lt_flights_all2 IN lt_filter WHERE carrier_id = table_line ) .
    data(lt_flights_final2) =  FILTER #( lt_flights_all2 EXCEPT IN lt_filter  WHERE carrier_id eq table_line ) .
    out->write( lt_flights_all2 ).
    out->write( lt_flights_final1 ).
    out->write( lt_flights_final2 ).

data(lv_char) = '2'.

  ENDMETHOD.
ENDCLASS.
