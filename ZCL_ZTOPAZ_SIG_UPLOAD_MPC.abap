class ZCL_ZTOPAZ_SIG_UPLOAD_MPC_EXT definition
  public
  inheriting from ZCL_ZTOPAZ_SIG_UPLOAD_MPC
  create public .

public section.

  methods DEFINE
    redefinition .
protected section.
private section.
ENDCLASS.



CLASS ZCL_ZTOPAZ_SIG_UPLOAD_MPC_EXT IMPLEMENTATION.


  method DEFINE.

              super->define( ).
*      CATCH /iwbep/cx_mgw_med_exception.
    .
    DATA: lo_entity   TYPE REF TO /iwbep/if_mgw_odata_entity_typ,
          lo_property TYPE REF TO /iwbep/if_mgw_odata_property.

    lo_entity = model->get_entity_type( iv_entity_name = 'DeliveryDocument' ).

    IF lo_entity IS BOUND.
      lo_property = lo_entity->get_property( iv_property_name = 'DeliveryNumber' ).

      lo_property->set_as_content_type( ).
*      CATCH /iwbep/cx_mgw_med_exception. " Meta data exception
    ENDIF.
  endmethod.
ENDCLASS.
