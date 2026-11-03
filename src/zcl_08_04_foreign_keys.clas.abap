CLASS zcl_08_04_foreign_keys DEFINITION
  PUBLIC
  FINAL
  CREATE PUBLIC.

  PUBLIC SECTION.
    INTERFACES if_oo_adt_classrun.

  PRIVATE SECTION.
    TYPES:
      BEGIN OF ty_foreign_key,
        field_name   TYPE string,
        check_table  TYPE string,
        key_type     TYPE string,
        cardinality  TYPE string,
        screen_check TYPE abap_bool,
      END OF ty_foreign_key,
      tt_foreign_keys TYPE STANDARD TABLE OF ty_foreign_key WITH EMPTY KEY,

      BEGIN OF ty_assignment,
        field_name        TYPE string,
        check_field       TYPE string,
        foreign_key_table TYPE string,
        foreign_key_field TYPE string,
      END OF ty_assignment,
      tt_assignments TYPE STANDARD TABLE OF ty_assignment WITH EMPTY KEY,

      BEGIN OF ty_reference,
        field_name      TYPE string,
        reference_table TYPE string,
        reference_field TYPE string,
      END OF ty_reference,
      tt_references TYPE STANDARD TABLE OF ty_reference WITH EMPTY KEY,

      tt_fleet TYPE STANDARD TABLE OF ztb_08_04_fleet WITH EMPTY KEY.

    CONSTANTS c_table TYPE sxco_dbt_object_name VALUE 'ZTB_08_04_FLEET'.

ENDCLASS.


CLASS zcl_08_04_foreign_keys IMPLEMENTATION.

  METHOD if_oo_adt_classrun~main.
    out->write( '=== CLASS 8.04: FOREIGN KEYS, SEMANTIC ATTRIBUTES AND RELATIONSHIPS ===' ).
    out->write( ' ' ).

    DATA lt_foreign_keys TYPE tt_foreign_keys.
    DATA lt_assignments  TYPE tt_assignments.
    DATA lt_references   TYPE tt_references.

    LOOP AT xco_cp_abap_dictionary=>database_table( c_table )->fields->all->get( ) INTO DATA(lo_field).
      IF lo_field->foreign_key->exists( ).
        DATA(ls_fk) = lo_field->foreign_key->content( )->get( ).
        APPEND VALUE #( field_name   = lo_field->name
                        check_table  = COND #( WHEN ls_fk-check_table IS BOUND THEN ls_fk-check_table->name )
                        key_type     = COND #( WHEN ls_fk-key_type IS BOUND THEN ls_fk-key_type->value )
                        cardinality  = |[{ COND #( WHEN ls_fk-cardinality-left_cardinality IS BOUND
                                                   THEN ls_fk-cardinality-left_cardinality->value ) },{
                                           COND #( WHEN ls_fk-cardinality-right_cardinality IS BOUND
                                                   THEN ls_fk-cardinality-right_cardinality->value ) }]|
                        screen_check = ls_fk-screen_check ) TO lt_foreign_keys.
        LOOP AT ls_fk-field_assignments INTO DATA(ls_assignment).
          APPEND VALUE #( field_name        = lo_field->name
                          check_field       = ls_assignment-check_field
                          foreign_key_table = ls_assignment-foreign_key_table
                          foreign_key_field = ls_assignment-foreign_key_field ) TO lt_assignments.
        ENDLOOP.
      ENDIF.

      DATA(ls_reference) = lo_field->content( )->get_currency_quantity( ).
      IF ls_reference-reference_field IS NOT INITIAL.
        APPEND VALUE #( field_name      = lo_field->name
                        reference_table = ls_reference-reference_table
                        reference_field = ls_reference-reference_field ) TO lt_references.
      ENDIF.
    ENDLOOP.

    out->write( |--- Step 1: Foreign keys defined in { c_table } ---| ).
    out->write( lt_foreign_keys ).
    out->write( ' ' ).

    out->write( '--- Step 2: Field assignments (foreign key field -> check table field) ---' ).
    out->write( lt_assignments ).
    out->write( ' ' ).

    out->write( '--- Step 3: Semantic attributes - currency and unit references ---' ).
    out->write( lt_references ).
    out->write( ' ' ).

    out->write( '--- Step 4: Insert test data, including one row that breaks the foreign keys ---' ).
    DELETE FROM ztb_08_04_fleet.
    DATA(lt_fleet) = VALUE tt_fleet(
      ( carrier_id = 'LH' aircraft_id = 'D-AIMA' model = 'Airbus A380-800'  seats_max = 509 home_airport = 'FRA'
        max_weight = '575000.00' weight_unit = 'KG' purchase_price = '445000000.00' currency_code = 'EUR' )
      ( carrier_id = 'LH' aircraft_id = 'D-AIXA' model = 'Airbus A350-900'  seats_max = 293 home_airport = 'MUC'
        max_weight = '280000.00' weight_unit = 'KG' purchase_price = '317000000.00' currency_code = 'EUR' )
      ( carrier_id = 'AA' aircraft_id = 'N717AN' model = 'Boeing 777-300ER' seats_max = 304 home_airport = 'JFK'
        max_weight = '351500.00' weight_unit = 'KG' purchase_price = '375000000.00' currency_code = 'USD' )
      ( carrier_id = 'UA' aircraft_id = 'N2645U' model = 'Boeing 787-10'    seats_max = 318 home_airport = 'SFO'
        max_weight = '254000.00' weight_unit = 'KG' purchase_price = '338000000.00' currency_code = 'USD' )
      ( carrier_id = 'SQ' aircraft_id = '9V-SKA' model = 'Airbus A380-800'  seats_max = 471 home_airport = 'SIN'
        max_weight = '575000.00' weight_unit = 'KG' purchase_price = '445000000.00' currency_code = 'SGD' )
      ( carrier_id = 'ZZ' aircraft_id = 'X-ORPHAN' model = 'Unknown'        seats_max = 100 home_airport = 'XXX'
        max_weight = '50000.00'  weight_unit = 'KG' purchase_price = '1000000.00'   currency_code = 'EUR' ) ).
    INSERT ztb_08_04_fleet FROM TABLE @lt_fleet.
    out->write( |INSERT sy-subrc = { sy-subrc } - inserted rows: { sy-dbcnt }| ).
    out->write( ' ' ).

    out->write( '--- Step 5: Detect orphan rows (no matching entry in the check table) ---' ).
    SELECT FROM ztb_08_04_fleet AS fleet
      LEFT OUTER JOIN /dmo/carrier AS carrier
        ON carrier~carrier_id = fleet~carrier_id
      LEFT OUTER JOIN /dmo/airport AS airport
        ON airport~airport_id = fleet~home_airport
      FIELDS fleet~carrier_id,
             fleet~aircraft_id,
             fleet~home_airport,
             CASE WHEN carrier~carrier_id IS NULL THEN 'MISSING' ELSE 'OK' END AS carrier_check,
             CASE WHEN airport~airport_id IS NULL THEN 'MISSING' ELSE 'OK' END AS airport_check
      ORDER BY fleet~carrier_id, fleet~aircraft_id
      INTO TABLE @DATA(lt_integrity).
    out->write( lt_integrity ).
    out->write( ' ' ).

    out->write( '--- Step 6: Validate a value against the check table before saving ---' ).
    DATA(lt_candidates) = VALUE string_table( ( `LH` ) ( `ZZ` ) ( `SQ` ) ( `XY` ) ).
    LOOP AT lt_candidates INTO DATA(lv_candidate).
      DATA(lv_carrier_id) = CONV /dmo/carrier_id( lv_candidate ).
      SELECT SINGLE FROM /dmo/carrier
        FIELDS @abap_true
        WHERE carrier_id = @lv_carrier_id
        INTO @DATA(lv_exists).
      out->write( |Carrier { lv_carrier_id }: { COND string( WHEN lv_exists = abap_true THEN `valid` ELSE `rejected` ) }| ).
      CLEAR lv_exists.
    ENDLOOP.
    out->write( ' ' ).

    out->write( '--- Step 7: Follow the relationships - fleet with carrier and airport data ---' ).
    SELECT FROM ztb_08_04_fleet AS fleet
      INNER JOIN /dmo/carrier AS carrier
        ON carrier~carrier_id = fleet~carrier_id
      INNER JOIN /dmo/airport AS airport
        ON airport~airport_id = fleet~home_airport
      FIELDS fleet~carrier_id,
             carrier~name AS carrier_name,
             fleet~aircraft_id,
             fleet~model,
             airport~city AS home_city,
             fleet~max_weight,
             fleet~weight_unit,
             fleet~purchase_price,
             fleet~currency_code
      ORDER BY fleet~carrier_id, fleet~aircraft_id
      INTO TABLE @DATA(lt_relations).
    out->write( lt_relations ).
  ENDMETHOD.

ENDCLASS.

