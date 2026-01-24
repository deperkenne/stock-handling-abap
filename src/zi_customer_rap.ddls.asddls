@AbapCatalog.viewEnhancementCategory: [#NONE]
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Customer Interface View'
@Metadata.ignorePropagatedAnnotations: true

define root view  entity ZI_CUSTOMER_RAP as select from zrap_customer
{
    key customer_id as CustomerId,
    first_name as FirstName,
    last_name as LastName,
    email as Email,
    country as Country,       
    city    as City,       
    street  as Street,
    house_number as HouseNumber,
    postalcode   as PostalCode
       
}
