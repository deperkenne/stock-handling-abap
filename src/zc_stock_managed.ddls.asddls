@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cons Stock managed'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_STOCK_MANAGED 
  provider contract transactional_query
  as projection on ZI_STOCK_MANAGED
{
    key StockId,
    ProductId,
    SkuId,
    ProductName,
    @Semantics.amount.currencyCode: 'Currency'
    UnitPrice,
    Currency,
    @Semantics.quantity.unitOfMeasure : 'Unit'
    Quantity as Quantity,
    Unit as Unit
}
