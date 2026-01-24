@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'STock reservation interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_ORDER_RES as select from zstock_res
{
    key stock_res_uuid as StockResUuid,
    order_uuid as OrderUuid,
    item_uuid as ItemUuid,
    product_id as ProductId,
    @Semantics.quantity.unitOfMeasure : 'Unit'
    res_quantity as ResQuantity,
    unit as Unit
  
}
