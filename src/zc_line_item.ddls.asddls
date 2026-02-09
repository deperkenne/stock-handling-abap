@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Line item Conso'
@Metadata.ignorePropagatedAnnotations: true
define  view entity ZC_LINE_ITEM 
  as projection on ZILINE_ITEM
{
    key ItemUuid,
    OrderUuid,
    ItemId,
    ProductId,
    ProductName,
    @Semantics.quantity.unitOfMeasure : 'Unit'
    Quantity,
    Unit,
    @Semantics.amount.currencyCode: 'Currency'
    Price,
    Currency,
    @Semantics.amount.currencyCode: 'Currency'
    GrossAmount,
    CreatedAt,
    CreatedAtNew,
    LocalLastChangedAt,
    LastChangedAt,
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CALC_TOTAL_QTY'
    @Semantics.quantity.unitOfMeasure : 'Unit' 
    virtual TotalProductQty : abap.quan(13,3),    
    @ObjectModel.virtualElementCalculatedBy: 'ABAP:ZCL_CALC_TOTAL_QTY'
    @Semantics.amount.currencyCode  : 'Currency' 
    virtual TotalAmount :  abap.curr(15,2),
    /* Associations */
    _Order : redirected to parent ZC_ORDER  
}
