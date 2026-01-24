@AbapCatalog.viewEnhancementCategory: [ #NONE ]
@EndUserText.label: 'Customer Consumption View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.ignorePropagatedAnnotations: true
@Metadata.allowExtensions: true

// DTO request show to the client what he going to see
define root view entity ZC_CUSTOMER_RAP
  provider contract transactional_query
  as projection on ZI_CUSTOMER_RAP
{
      key  CustomerId,
      FirstName,
      LastName,
      Email,
      Country,
      City,
      Street,
      HouseNumber,
      PostalCode
}
