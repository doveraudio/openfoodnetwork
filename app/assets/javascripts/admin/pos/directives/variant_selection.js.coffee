angular.module("admin.pos").directive "variantSelect", ($timeout) ->
  restrict: 'C'
  link: (scope, element, attrs) ->
    selecting = false
    currentIndex = 0

    element.bind "keydown", (event) ->
      if selecting && event.which in [37,38,39,40]
        event.preventDefault()

    element.bind "keyup", (event) ->
      if selecting
        if event.which in [13,37,38,39,40]
          switch event.which
            when 13
              scope.addLineItem(scope.selectedVariant)
            when 37 # left
              currentIndex = Math.max(currentIndex - (currentIndex % 5),currentIndex-1)
            when 38 # up
              currentIndex = if currentIndex - 5 >= 0 then currentIndex - 5 else currentIndex
            when 39 # right
              currentIndex = if Math.floor(currentIndex/5) == Math.floor((currentIndex+1)/5) && currentIndex + 1 < scope.filteredVariants.length then currentIndex + 1 else currentIndex
            when 40 # down
              currentIndex = Math.min(currentIndex + 5, scope.filteredVariants.length - 1)
          scope.$apply ->
            scope.selectedVariant = scope.filteredVariants[currentIndex]
        else
          selecting = false
          scope.$apply ->
            currentIndex = 0
            scope.selectedVariant = null
      else if event.which == 40
        selecting = true
        element.select()
        scope.$apply ->
          currentIndex = 0
          scope.selectedVariant = scope.filteredVariants[0]
