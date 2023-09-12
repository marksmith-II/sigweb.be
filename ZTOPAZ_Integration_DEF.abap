@EndUserText.label: 'Topaz Integration'
define service ZTOPAZ_Integration_DEF {
  expose ztopaz_delivery_items as DeliveryItems;
  expose ztopaz_customer_cert_status as CustomerCertStatus;
  expose Ztopaz_del_po_cust_info as DeliveryPOCustomerInfo;
}
