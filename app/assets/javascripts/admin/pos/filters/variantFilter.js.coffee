angular.module("admin.pos").filter "posFilter", ($filter) ->
  return (variants, query) ->
    return variants unless query
    return $filter('filter')(variants, (variant) ->
      return (variant.full_name.toLowerCase().indexOf(query.toLowerCase()) >= 0 || variant.product.name.toLowerCase().indexOf(query.toLowerCase()) >= 0)
    , true)
