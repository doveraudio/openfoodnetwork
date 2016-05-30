angular.module("admin.pos").factory "Variants", (variants) ->
  new class Variants
    all: []
    byID: {}

    constructor: ->
      for variant in variants
        @all.push variant
        @byID[variant.id] = variant

    linkToProducts: (productsByID) ->
      for variant in @all
        variant.product = productsByID[variant.product.id]
        variant.product.variants ||= []
        variant.product.variants.push variant
