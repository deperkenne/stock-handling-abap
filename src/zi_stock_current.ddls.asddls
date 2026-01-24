@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Interface Current Stock'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_STOCK_CURRENT as select from ztstock_current
association [1..1] to ZKENNE_I_PRODUCT as _Product on $projection.ProductId = _Product.ProductId
association [1..1] to ZI_STOCK_MANAGED as _Stock on $projection.StockId = _Stock.StockId
{
    key current_id as CurrentId,
    product_id as ProductId,
    stock_id  as StockId,
    remaining as Remaining,
    @Semantics.amount.currencyCode: 'Currency'
    unit_price as UnitPrice,
    currency as Currency,
    _Product,
    _Stock
}
