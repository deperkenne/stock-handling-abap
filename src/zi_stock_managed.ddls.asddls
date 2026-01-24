@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Stock managed'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_STOCK_MANAGED as select from ztstock
association [1..1] to ZKENNE_I_PRODUCT as _Product on $projection.ProductId = _Product.ProductId
association [1..1] to ZI_SKU as _Sku on $projection.SkuId = _Sku.SkuId
{
    key stock_id as StockId,
    product_id as ProductId,
    sku_id as SkuId,
    product_name as ProductName,
    @Semantics.quantity.unitOfMeasure : 'Unit'
    quantity as Quantity,
    @Semantics.quantity.unitOfMeasure : 'unit'
    quantity_reserved  as QuantityReserved,
    @Semantics.quantity.unitOfMeasure : 'unit'
    available_quantity as AvailableQuantity,
    unit as Unit,
    @Semantics.amount.currencyCode : 'currency'
    unit_price      as UnitPrice,
    currency        as Currency,
      // Corrigé le nom (mais vérifiez le nom du champ en base)
    created_at as CreatedAt,
    changed_at as ChangedAt,
    _Product,
    _Sku   
}
