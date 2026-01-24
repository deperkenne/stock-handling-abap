@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface scheduled stock'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_STOCK_SCHEDULED as select from ztstock_schedule
association [1..1] to ZKENNE_I_PRODUCT as _Product on $projection.ProductId = _Product.ProductId
association [1..1] to ZI_STOCK_MANAGED as _Stock on $projection.StockId = _Stock.StockId

{
    key scheduled_id as ScheduledId,
    item_uuid as ItemUuid,
    product_id as ProductId,
    stock_id as StockId,
    type as Type,
    quantity as Quantity,
    @Semantics.amount.currencyCode: 'Currency'
    unit_price as UnitPrice,
    currency as Currency,
    created_at as CreatedAt,
    _Product,
    _Stock
}
