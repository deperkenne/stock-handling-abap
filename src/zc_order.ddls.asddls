@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Cds Consomation Order'
@Metadata.ignorePropagatedAnnotations: true

// it is called cds transactional interface
define root view entity ZC_ORDER 
 provider contract transactional_query
  as projection on  ZI_ORDER_K
{
   // @UI.hidden: true              // ✅ Caché dans l'interface utilisateur
    key OrderUuid, 
    OrderId,
    CustomerId,
    @Semantics.amount.currencyCode: 'Currency'
    TotalAmount,
    Currency,
    Status,
    _Items : redirected to composition child ZC_LINE_ITEM
    
}
