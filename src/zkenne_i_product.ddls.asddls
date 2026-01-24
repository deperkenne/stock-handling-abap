@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Interface View'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZKENNE_I_PRODUCT as select from ztproduct
{
    key product_id as ProductId,
    productname as Productname,
    @Semantics.amount.currencyCode: 'Currency'
    price as Price,
    currency as Currency,
    status as Status,
    stock as Stock
}
