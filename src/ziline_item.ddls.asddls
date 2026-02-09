@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Line Item View'
@Metadata.ignorePropagatedAnnotations: true
define  view entity ZILINE_ITEM as select from ztline_item
 association to parent ZI_ORDER_K as _Order
    on $projection.OrderUuid = _Order.OrderUuid  // Utiliser UUID ici !
  association [1..1] to ZKENNE_I_PRODUCT as _Product
    on $projection.ProductId = _Product.ProductId
{
    key item_uuid as  ItemUuid,
    order_uuid  as OrderUuid,
    item_id  as ItemId,
    order_id as OrderId,
    product_id as ProductId,
    product_name as ProductName,
    @Semantics.quantity.unitOfMeasure : 'Unit'
    quantity as Quantity,
    unit as Unit,
    @Semantics.amount.currencyCode: 'Currency'
    price as Price,
    currency as Currency,
    @Semantics.amount.currencyCode: 'Currency'
    grossamount as GrossAmount,
    created_at as CreatedAt,
    @Semantics.systemDateTime.createdAt: true
    created_at_new as CreatedAtNew,
    @Semantics.systemDateTime.localInstanceLastChangedAt: true
    local_last_changed_at as LocalLastChangedAt,
    @Semantics.systemDateTime.lastChangedAt: true
    last_changed_at as LastChangedAt,
    _Order,
    _Product
    
}
