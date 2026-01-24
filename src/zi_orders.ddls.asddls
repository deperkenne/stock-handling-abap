@AbapCatalog.sqlViewName: 'ZORD_H_SQL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Orders Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view ZI_ORDERS as select from zorders_h
  composition [0..*] of ZI_ORDER_ITEM as _Items
  association [1..1] to zrap_customer as _Customer 
  on $projection.CustomerId = _Customer.customer_id
{
    key order_uuid as OrderUuid,
    order_id  as OderId,
    customer_id as CustomerId,
    total_amount as TotalAmount,
    currency as Currency,
    created_at as CreatedAt,
    _Items,
    _Customer
    
}
