@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cons Sku'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZC_SKU 
   provider contract transactional_query
  as projection on ZI_SKU
{
    key SkuId,
    ProductId,
    Color,
    IsLock,
    Packaging,
    /* Associations */
    _Product
    
    
}
