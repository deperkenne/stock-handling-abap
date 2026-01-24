@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Sku  interface'
@Metadata.ignorePropagatedAnnotations: true
define root view entity ZI_SKU as select from ztsku as sku
association [0..1] to ZKENNE_I_PRODUCT as _Product  on $projection.ProductId = _Product.ProductId
{
    key sku.sku_id as SkuId,
    sku.product_id as ProductId,
    sku.color as Color,
    sku.is_lock as IsLock,
    packaging as Packaging,
    _Product
    
}
