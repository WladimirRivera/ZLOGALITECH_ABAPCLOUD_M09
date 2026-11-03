CLASS zcl_08_05_data_model DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_relation,
        table_name  TYPE string,
        field_name  TYPE string,
        check_table TYPE string,
        cardinality TYPE string,
        key_type    TYPE string,
      END OF ty_relation,
      tt_relations TYPE STANDARD TABLE OF ty_relation WITH EMPTY KEY,

      BEGIN OF ty_integrity,
        relation    TYPE string,
        orphan_rows TYPE i,
      END OF ty_integrity,
      tt_integrity TYPE STANDARD TABLE OF ty_integrity WITH EMPTY KEY,

      tt_programs TYPE STANDARD TABLE OF ztb_08_05_loyprg WITH EMPTY KEY,
      tt_members  TYPE STANDARD TABLE OF ztb_08_05_member WITH EMPTY KEY,
      tt_points   TYPE STANDARD TABLE OF ztb_08_05_points WITH EMPTY KEY.

    METHODS read_relations
      IMPORTING iv_table            TYPE sxco_dbt_object_name
      RETURNING VALUE(rt_relations) TYPE tt_relations.

    METHODS check_integrity
      RETURNING VALUE(rt_integrity) TYPE tt_integrity.

ENDCLASS.


CLASS zcl_08_05_data_model IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 8.05: RELATIONAL DATA MODEL - LOYALTY PROGRAM ===' ).
    out->write( ' ' ).

    out->write( '--- Step 1: Data model - tables and foreign key relationships ---' ).
    DATA(lt_relations) = VALUE tt_relations( ( LINES OF read_relations( 'ZTB_08_05_LOYPRG' ) )
                                             ( LINES OF read_relations( 'ZTB_08_05_MEMBER' ) )
                                             ( LINES OF read_relations( 'ZTB_08_05_POINTS' ) ) ).
    out->write( lt_relations ).
    out->write( ' ' ).

    out->write( '--- Step 2: Allowed tier values (domain ZDO_08_05_TIER) ---' ).
    DATA lt_tier_values TYPE string_table.
    LOOP AT xco_cp_abap_dictionary=>domain( 'ZDO_08_05_TIER' )->fixed_values->all->get( ) INTO DATA(lo_tier).
      APPEND |{ lo_tier->lower_limit } = { lo_tier->content( )->get( )-description }| TO lt_tier_values.
    ENDLOOP.
    out->write( lt_tier_values ).
    out->write( ' ' ).

    out->write( '--- Step 3: Reset the model (children first, then parents) ---' ).
    DELETE FROM ztb_08_05_points.
    out->write( |ZTB_08_05_POINTS : { sy-dbcnt } rows deleted| ).
    DELETE FROM ztb_08_05_member.
    out->write( |ZTB_08_05_MEMBER : { sy-dbcnt } rows deleted| ).
    DELETE FROM ztb_08_05_loyprg.
    out->write( |ZTB_08_05_LOYPRG : { sy-dbcnt } rows deleted| ).
    out->write( ' ' ).

    out->write( '--- Step 4: Load parents - loyalty programs ---' ).
    DATA(lt_programs) = VALUE tt_programs(
      ( program_id = 'LH-MILES'  carrier_id = 'LH' program_name = 'Miles & More' points_per_100 = 10 valid_from = '20250101' )
      ( program_id = 'AA-ADVANT' carrier_id = 'AA' program_name = 'AAdvantage'   points_per_100 = 12 valid_from = '20250101' )
      ( program_id = 'SQ-KRIS'   carrier_id = 'SQ' program_name = 'KrisFlyer'    points_per_100 = 8  valid_from = '20250101' ) ).
    INSERT ztb_08_05_loyprg FROM TABLE @lt_programs.
    out->write( |Programs inserted: { sy-dbcnt }| ).
    out->write( lt_programs ).
    out->write( ' ' ).

    out->write( '--- Step 5: Load members - customers who flew with these carriers ---' ).
    SELECT FROM /dmo/booking
      FIELDS DISTINCT customer_id, carrier_id
      WHERE carrier_id IN ( 'LH', 'AA', 'SQ' )
      ORDER BY customer_id, carrier_id
      INTO TABLE @DATA(lt_candidates)
      UP TO 12 ROWS.

    DATA(lt_tiers) = VALUE string_table( ( `B` ) ( `S` ) ( `G` ) ( `P` ) ).
    DATA lt_members TYPE tt_members.
    LOOP AT lt_candidates INTO DATA(ls_candidate).
      APPEND VALUE #( member_id   = sy-tabix
                      program_id  = lt_programs[ carrier_id = ls_candidate-carrier_id ]-program_id
                      customer_id = ls_candidate-customer_id
                      tier        = lt_tiers[ ( sy-tabix - 1 ) MOD 4 + 1 ]
                      joined_on   = '20250115' ) TO lt_members.
    ENDLOOP.
    INSERT ztb_08_05_member FROM TABLE @lt_members.
    out->write( |Members inserted: { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Step 6: Load children - points earned per booking ---' ).
    DATA lt_points TYPE tt_points.
    LOOP AT lt_members ASSIGNING FIELD-SYMBOL(<ls_member>).
      DATA(ls_program) = lt_programs[ program_id = <ls_member>-program_id ].
      SELECT FROM /dmo/booking
        FIELDS travel_id, booking_id, flight_price
        WHERE customer_id = @<ls_member>-customer_id
          AND carrier_id  = @ls_program-carrier_id
        ORDER BY travel_id, booking_id
        INTO TABLE @DATA(lt_bookings).
      LOOP AT lt_bookings INTO DATA(ls_booking).
        DATA(lv_points) = CONV i( ls_booking-flight_price * ls_program-points_per_100 / 100 ).
        APPEND VALUE #( member_id      = <ls_member>-member_id
                        transaction_no = sy-tabix
                        travel_id      = ls_booking-travel_id
                        booking_id     = ls_booking-booking_id
                        points         = lv_points
                        posted_on      = '20250201' ) TO lt_points.
        <ls_member>-points_balance += lv_points.
      ENDLOOP.
    ENDLOOP.
    INSERT ztb_08_05_points FROM TABLE @lt_points.
    out->write( |Point transactions inserted: { sy-dbcnt }| ).
    UPDATE ztb_08_05_member FROM TABLE @lt_members.
    out->write( |Member balances updated: { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Step 7: Navigate the model through CDS associations ---' ).
    SELECT FROM zcds_i_08_05_member
      FIELDS MemberId,
             \_Customer-first_name  AS FirstName,
             \_Customer-last_name   AS LastName,
             \_Program-program_name AS ProgramName,
             Tier,
             PointsBalance
      ORDER BY PointsBalance DESCENDING
      INTO TABLE @DATA(lt_member_view).
    out->write( lt_member_view ).
    out->write( ' ' ).

    out->write( '--- Step 8: Points per program and tier ---' ).
    SELECT FROM zcds_i_08_05_member
      FIELDS \_Program-program_name AS ProgramName,
             Tier,
             COUNT(*)               AS Members,
             SUM( PointsBalance )   AS TotalPoints
      GROUP BY \_Program-program_name, Tier
      ORDER BY ProgramName, Tier
      INTO TABLE @DATA(lt_summary).
    out->write( lt_summary ).
    out->write( ' ' ).

    out->write( '--- Step 9: Referential integrity check ---' ).
    out->write( check_integrity( ) ).
    out->write( ' ' ).

    out->write( '--- Step 10: Delete a parent row without handling its children ---' ).
    DELETE FROM ztb_08_05_loyprg WHERE program_id = 'SQ-KRIS'.
    out->write( |DELETE program SQ-KRIS: sy-subrc = { sy-subrc }, rows = { sy-dbcnt }| ).
    out->write( check_integrity( ) ).
    out->write( ' ' ).

    out->write( '--- Step 11: Restore the parent row ---' ).
    INSERT ztb_08_05_loyprg FROM @( lt_programs[ program_id = 'SQ-KRIS' ] ).
    out->write( |INSERT program SQ-KRIS: sy-subrc = { sy-subrc }| ).
    out->write( check_integrity( ) ).
  ENDMETHOD.


  METHOD read_relations.
    LOOP AT xco_cp_abap_dictionary=>database_table( iv_table )->fields->all->get( ) INTO DATA(lo_field).
      IF lo_field->foreign_key->exists( ).
        DATA(ls_fk) = lo_field->foreign_key->content( )->get( ).
        APPEND VALUE #( table_name  = iv_table
                        field_name  = lo_field->name
                        check_table = COND #( WHEN ls_fk-check_table IS BOUND THEN ls_fk-check_table->name )
                        cardinality = |[{ COND #( WHEN ls_fk-cardinality-left_cardinality IS BOUND
                                                  THEN ls_fk-cardinality-left_cardinality->value ) },{
                                          COND #( WHEN ls_fk-cardinality-right_cardinality IS BOUND
                                                  THEN ls_fk-cardinality-right_cardinality->value ) }]|
                        key_type    = COND #( WHEN ls_fk-key_type IS BOUND THEN ls_fk-key_type->value ) ) TO rt_relations.
      ENDIF.
    ENDLOOP.
  ENDMETHOD.


  METHOD check_integrity.
    SELECT FROM ztb_08_05_member AS member
      LEFT OUTER JOIN ztb_08_05_loyprg AS program
        ON program~program_id = member~program_id
      FIELDS COUNT(*)
      WHERE program~program_id IS NULL
      INTO @DATA(lv_no_program).

    SELECT FROM ztb_08_05_member AS member
      LEFT OUTER JOIN /dmo/customer AS customer
        ON customer~customer_id = member~customer_id
      FIELDS COUNT(*)
      WHERE customer~customer_id IS NULL
      INTO @DATA(lv_no_customer).

    SELECT FROM ztb_08_05_points AS points
      LEFT OUTER JOIN ztb_08_05_member AS member
        ON member~member_id = points~member_id
      FIELDS COUNT(*)
      WHERE member~member_id IS NULL
      INTO @DATA(lv_no_member).

    SELECT FROM ztb_08_05_points AS points
      LEFT OUTER JOIN /dmo/booking AS booking
        ON  booking~travel_id  = points~travel_id
        AND booking~booking_id = points~booking_id
      FIELDS COUNT(*)
      WHERE booking~booking_id IS NULL
      INTO @DATA(lv_no_booking).

    rt_integrity = VALUE #( ( relation = `MEMBER -> LOYPRG`     orphan_rows = lv_no_program )
                            ( relation = `MEMBER -> /DMO/CUSTOMER` orphan_rows = lv_no_customer )
                            ( relation = `POINTS -> MEMBER`      orphan_rows = lv_no_member )
                            ( relation = `POINTS -> /DMO/BOOKING` orphan_rows = lv_no_booking ) ).
  ENDMETHOD.

ENDCLASS.

