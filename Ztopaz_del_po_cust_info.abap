@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Delivery, PO & Customer Information'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity Ztopaz_del_po_cust_info as select from ztopaz_del_po_base
association [0..1] to Ztopaz_customer as _customer on _customer.CustomerNumber = $projection.CustomerNumber



{
key ztopaz_del_po_base.DeliveryNumber as DeliveryNumber,
ztopaz_del_po_base.SalesOrder as SalesOrder,
ztopaz_del_po_base.PONumber as PONumber,
ztopaz_del_po_base.CustomerNumber as CustomerNumber,
_customer.CustomerName as Customer
    
}
