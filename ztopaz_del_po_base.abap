@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Delivery & PO information'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ztopaz_del_po_base as select from lips
association [1] to vbak as _vbak on _vbak.vbeln = $projection.SalesOrder



{

key vbeln as DeliveryNumber,
vgbel as SalesOrder,
_vbak.bstnk as PONumber,
_vbak.kunnr as CustomerNumber


    
}
