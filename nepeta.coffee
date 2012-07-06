(($) ->
  $.fn.filtermenu = (opts) ->
    settings = $.extend(
      columns: [ 1 ]
      bodyId: ""
      bodyIndex: 0
      headIndex: 0
      resetValue: "##FILTERMENU.RESET##"
      curFilters: []
    , opts)
    table = this
    $.each settings.columns, (index, curCol) ->
      body = table.find("tbody" + settings.bodyId).eq(settings.bodyIndex)
      head = table.find("thead").eq(settings.headIndex)
      select = $("<select/>")
      col = ":nth-child(#{curCol})"
      firstRun = true
      
      
      unfiltered = (cCol) ->
        $.each settings.curFilters, (index, item) ->
           item.column isnt cCol
 
      buildSelect = (selector) ->
        intCol = selector.replace /\D/g, ""
        itemsArray = []
        box = head.find("tr>*#{selector}").find("select")
        if box.length is 0
          box = select.clone true
        else
          box.detach()
          box = select.clone true
        box.addClass "FilterColumn_#{intCol}"
        body.find("tr>td" + selector).filter(":visible").each ->
          if firstRun
            $(this).addClass "FilterColumn_#{curCol}"
          itemsArray.push $(this).text()
        firstRun = false
        firstOpt = $ "<option />", value: settings.resetValue, text: "Choose Filter"
        ###
        if unfiltered intCol
          firstOpt.text "Choose Filter"
        else
          firstOpt.text "Remove Filter"
        ###
        box.append firstOpt
        itemsArray = $.grep itemsArray, (el, index) ->
          index is $.inArray el, itemsArray
        $.each itemsArray, (index, item) ->
          curOpt = $ "<option />", value: item
          if $.trim(item)? and $.trim(item) isnt ""
            curOpt.text item
          else
            curOpt.text "None"
          box.append curOpt
        box.prop "selectedIndex", 1
        head.find("tr>*#{selector}").each ->
          selectBox = box.clone true
          $(this).append selectBox

      rebuild = (c) ->
        $.each $.grep(settings.columns, (el, index) ->
          unfiltered "#{el}"
        ), (index, item) ->
          buildSelect ":nth-child(#{item})"

      select.change (evt) ->
        sBox = $ this
        chk = sBox.val()
        cColumn = sBox.attr("class").replace(/\D/g, "")
        selector = ":nth-child(#{cColumn})"
        sBox.hide()
        if chk isnt settings.resetValue
          settings.curFilters.push
            column: cColumn
            value: chk
          body.find("tr").filter(":visible").filter((i) ->
            $(this).find("td#{selector}").text() isnt chk
          ).hide()
          clearLink = $ "<a>", { text: "(#{chk})" }
          clearLink.css {display: "block"}
          clearLink.click ->
            $(this).remove()
            popFilter = settings.curFilters.splice(settings.curFilters.indexOf({column: cColumn, value: chk}), 1)
            if settings.curFilters.length isnt 0
              body.find("tr").filter(":hidden").filter((i) ->
                row = $ this
                win = $.each settings.curFilters, (index, item) ->
                  console.log row.find("td:nth-child(#{item.column})")
                  console.log "checking to see if #{$.trim(row.find("td:nth-child(#{item.column})").text())} is #{$.trim(item.value)}"
                  win = $.trim($(this).find("td:nth-child(#{item.column})").text()) is $.trim(item.value)
                  console.log win
              ).show()
            else body.find("tr").filter(":hidden").show()
            sBox.show()
          clearLink.appendTo sBox.parent()
          rebuild cColumn

      buildSelect col
    this
) jQuery

