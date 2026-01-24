@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Product Conso'
@Metadata.ignorePropagatedAnnotations: true


define root  view entity ZC_PRODUCT  
  provider contract transactional_query
  as projection on ZKENNE_I_PRODUCT
{
    key ProductId,
    Productname,
    @Semantics.amount.currencyCode: 'Currency'
    Price,
    @Semantics.currencyCode: true
    Currency,
    Status,
    Stock
}
