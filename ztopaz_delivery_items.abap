@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Delivery Items'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ztopaz_delivery_items
  as select from I_DeliveryDocumentItem
  association  [1..1] to ztopaz_customer_cert_status as _customer_cert_status on _customer_cert_status.DeliveryDocument = $projection.DeliveryDocument
  association [1..1] to Ztopaz_del_po_cust_info as _deliveryPOCustomerInfo on _deliveryPOCustomerInfo.DeliveryNumber = $projection.DeliveryDocument
{

key DeliveryDocument,
key DeliveryDocumentItem,
DeliveryDocumentItemText,

Material,
@DefaultAggregation: #SUM
@Semantics.quantity.unitOfMeasure: 'DeliveryQuantityUnit'
ActualDeliveryQuantity,
DeliveryQuantityUnit,


//association
_customer_cert_status,
_deliveryPOCustomerInfo
}


where HigherLevelItem = '000000';
