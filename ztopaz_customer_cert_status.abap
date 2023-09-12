@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #CHECK
@EndUserText.label: 'Customer Disclaimer status'
@Metadata.ignorePropagatedAnnotations: true
@ObjectModel.usageType:{
    serviceQuality: #X,
    sizeCategory: #S,
    dataClass: #MIXED
}
define view entity ztopaz_customer_cert_status
  as select from vbfa
    inner join   vbpa as _vbpa on _vbpa.vbeln = vbfa.vbelv
    inner join   kna1 as _kna1 on _kna1.kunnr = _vbpa.kunnr
{

  key _kna1.kunnr as Customer,
  key vbfa.ruuid  as Rid,
  key vbfa.vbeln as  DeliveryDocument,
  key _vbpa.posnr as Item,
  //key _vbpa.parvw as PartnerFunction,


      case when
      _kna1.katr3 = '3A'
      then  cast('X' as char01)
      else
                cast('' as char01)
      end         as CustomerCertRequired




}
where
      vbfa.vbtyp_n = 'J'
  and vbfa.vbtyp_v = 'C'
  and vbfa.plmin   = '+'
  and _vbpa.parvw  = 'RG';
