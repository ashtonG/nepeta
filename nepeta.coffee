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
      
      ###
      unfiltered = (cCol) ->
        truthArray = []
        $.each settings.curFilters, (index, item) ->
          truthArray.push item.column is cCol
        $.inArray true, truthArray
      ###
      buildSelect = (selector) ->
        intCol = selector.replace /\D/g, ""
        itemsArray = []
        box = head.find("tr>*#{selector}").find("select")
        console.log "building for #{intCol}"
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
          el isnt c
        ), (index, item) ->
          buildSelect ":nth-child(#{item})"

      select.change (evt) ->
        console.log $ this
        console.log this
        sBox = $ this
        chk = sBox.val()
        cColumn = sBox.attr("class").replace(/\D/g, "")
        selector = ":nth-child(#{cColumn})"
        $(this).hide()
        if chk isnt settings.resetValue
          settings.curFilters.push
            column: cColumn
            value: chk
          body.find("tr").filter(":visible").filter((i) ->
            $(this).find("td#{selector}").text() isnt chk
          ).hide()
          clearLink = $ "<a>", { href: "#", text: "X" }
          clearLink.click ->
            $(this).detatch()
            settings.curFilters = $.grep settings.curFilters, (el, index) ->
              el.column isnt cColumn
            head.find("tr>*#{selector}").each ->
              $(this).append sBox
          rebuild cColumn

      buildSelect col
    this
) jQuery

