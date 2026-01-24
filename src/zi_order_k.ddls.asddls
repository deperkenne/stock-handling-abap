@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ORDER_K as select from ztorder
  composition [0..*] of ZILINE_ITEM as _Items
  association [1..1] to zrap_customer as _Customer
    on $projection.CustomerId = _Customer.customer_id
{
    key order_uuid as OrderUuid,
    order_id as OrderId,
    customer_id as CustomerId,
    @Semantics.amount.currencyCode: 'Currency'
    total_amount as TotalAmount,
    currency as Currency,
    created_at as CreatedAt,
    status as Status,
    _Items,
    _Customer
    
}
