CLASS zcl_03_08_itab_loop_processing DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC .

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun .

  PRIVATE SECTION.
    METHODS loop_basic_variants IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS loop_at_new_end_of  IMPORTING out TYPE REF TO if_oo_adt_classrun_out.
    METHODS loop_group_by       IMPORTING out TYPE REF TO if_oo_adt_classrun_out.

ENDCLASS.



CLASS zcl_03_08_itab_loop_processing IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== MODULE 3 / 18, 25: LOOP AT, AT NEW/END OF, GROUP BY ===' ).
    loop_basic_variants( out ).
    loop_at_new_end_of( out ).
    loop_group_by( out ).
  ENDMETHOD.

  METHOD loop_basic_variants.
    out->write( '--- LOOP AT: INTO, WHERE, TRANSPORTING NO FIELDS, FROM/TO ---' ).

    TYPES: BEGIN OF ty_article,
             reference TYPE string,
             quantity  TYPE i,
           END OF ty_article.

    DATA: lt_articles TYPE STANDARD TABLE OF ty_article WITH EMPTY KEY,
          ls_articles TYPE ty_article.

    lt_articles = VALUE #( ( reference = 'REF-001' quantity = 10 )
                            ( reference = 'REF-002' quantity = 0 )
                            ( reference = 'REF-003' quantity = 8 )
                            ( reference = 'REF-004' quantity = 15 ) ).

    ls_articles-reference = 'REF-005'.
    ls_articles-quantity = 15.
    APPEND ls_articles TO  lt_articles.

    LOOP AT lt_articles INTO DATA(ls_article) WHERE quantity > 0.
      out->write( |WHERE quantity > 0: { ls_article-reference } ({ ls_article-quantity })| ).
    ENDLOOP.

    DATA(lv_count) = 0.
    LOOP AT lt_articles TRANSPORTING NO FIELDS WHERE quantity > 5.
      lv_count = lv_count + 1.
    ENDLOOP.
    out->write( |TRANSPORTING NO FIELDS: { lv_count } row(s) match quantity > 5| ).

    LOOP AT lt_articles INTO ls_article FROM 2 TO 3.
      out->write( |FROM 2 TO 3: { ls_article-reference }| ).
    ENDLOOP.
  ENDMETHOD.

  METHOD loop_at_new_end_of.
    out->write( '--- AT NEW / AT END OF / SUM ---' ).
    out->write( 'AT NEW/AT END OF/SUM are classic list-processing statements and SUM' ).
    out->write( 'is not allowed in the ABAP Cloud language version used on this system.' ).
    out->write( 'The modern, always-valid replacement is LOOP AT ... GROUP BY, shown' ).
    out->write( 'in loop_group_by() below, which achieves the same subtotal-by-group result.' ).
  ENDMETHOD.

  METHOD loop_group_by.
    out->write( '--- LOOP AT ... GROUP BY: two-phase grouping ---' ).

    TYPES: BEGIN OF ty_sale,
             category TYPE string,
             product  TYPE string,
             units    TYPE i,
           END OF ty_sale.

    DATA lt_sales TYPE STANDARD TABLE OF ty_sale WITH EMPTY KEY.
    lt_sales = VALUE #( ( category = 'Electronics' product = 'Keyboard' units = 10 )
                        ( category = 'Electronics' product = 'Mouse'    units = 25 )
                        ( category = 'Home'        product = 'Lamp'     units = 5 ) ).

    LOOP AT lt_sales INTO DATA(ls_sale) GROUP BY ls_sale-category ASCENDING INTO DATA(lv_category).
      out->write( |Group: { lv_category }| ).

      DATA(lv_total_units) = 0.
      LOOP AT GROUP lv_category INTO DATA(ls_member).
        out->write( |  { ls_member-product }: { ls_member-units } unit(s)| ).
        lv_total_units = lv_total_units + ls_member-units.
      ENDLOOP.

      out->write( |  Total for { lv_category }: { lv_total_units }| ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
