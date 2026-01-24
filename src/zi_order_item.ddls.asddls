@AbapCatalog.sqlViewName: 'ZORDITEM_SQL'
@AbapCatalog.compiler.compareFilter: true
@AbapCatalog.preserveKey: true
@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Order Line Item Interface View'
@Metadata.ignorePropagatedAnnotations: true
define  view ZI_ORDER_ITEM as select from zorders_items
  association to parent ZI_ORDERS as _Order on $projection.ParentUuid = _Order.OrderUuid

{
    key item_uuid as ItemUuid,
    parent_uuid as ParentUuid,
    product_id as ProductId,
    quantity as Quantity,
    unit as Unit,
    price as Price,
    currency as Currency,
    _Order
}
