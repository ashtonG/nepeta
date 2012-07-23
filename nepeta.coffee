(($) ->
  $.fn.filtermenu = (opts) ->
    settings = $.extend(
      columns: [ 1 ]
      bodyId: ""
      bodyIndex: 0
      headIndex: 0
      resetValue: "##FILTERMENU.RESET##"
      curFilters: []
      headerSelect: false
      jqueryui: false
    , opts)
    table = this
    body = table.find("tbody" + settings.bodyId).eq(settings.bodyIndex)
    head = table.find("thead").eq(settings.headIndex)

    if settings.jqueryui
      table.toggleClass "ui-widget"
      head.toggleClass "ui-widget-header"
      body.toggleClass "ui-widget-content"
    $.each settings.columns, (index, curCol) ->
      select = $ "<select/>", class: "filter"
      col = ":nth-child(#{curCol})"
      firstRun = true
      
      stripToNumber = (str) -> str.replace /\D/g, ""
      
      unfiltered = (cCol) ->
        flag = true
        $.each settings.curFilters, (index, item) -> flag = item.column isnt cCol
        flag
 
      buildSelect = (selector) ->
        intCol = stripToNumber selector
        itemsArray = []
        sel = head.find("tr>*#{selector}").find("select").detach()
        fOpt = sel.children().eq(0)
        box = select.clone true
        box.addClass "FilterColumn_#{intCol}"
        body.find("tr>td" + selector).filter(":visible").each ->
          if firstRun
            $(this).addClass "FilterColumn_#{curCol}"
          itemsArray.push $(this).text()
        firstRun = false
        firstOpt = $ "<option />", value: settings.resetValue, text: if settings.headerSelect then head.find("tr>*#{selector}").text() else "Choose Filter"
        firstOpt = if fOpt.length != 0 then fOpt else firstOpt
        box.append firstOpt
        itemsArray = $.grep itemsArray, (el, index) -> index is $.inArray el, itemsArray
        $.each itemsArray, (index, item) ->
          curOpt = $ "<option />", value: item
          if $.trim(item)? and $.trim(item) isnt ""
            curOpt.text item
          else
            curOpt.text "None"
          box.append curOpt
        head.find("tr>*#{selector}").each ->
          selectBox = box.clone true
          if settings.headerSelect then $(this).empty()
          $(this).append selectBox

      rebuild = (x) ->
        $.each $("select.filter").filter(":visible"), (index, item) -> buildSelect ":nth-child(#{stripToNumber $(item).attr("class")})"

      select.change (evt) ->
        sBox = $ this
        chk = sBox.val()
        cColumn = stripToNumber sBox.attr("class")
        selector = ":nth-child(#{cColumn})"
        sBox.hide()
        if chk isnt settings.resetValue
          settings.curFilters.push
            column: cColumn
            value: chk
          body.find("tr").filter(":visible").filter((i) -> $(this).find("td#{selector}").text() isnt chk).hide()
          clearLink = $ "<a>", text: "(#{if $.trim(chk) isnt "" then $.trim chk else "None"})", class: """{"column": "#{cColumn}", "value":"#{$.trim chk}"}"""
          clearLink.css display: "block"
          clearLink.click ->
            filterObj = $.parseJSON $(this).attr("class")
            $(this).remove()
            sBox.prop "selectedIndex", 0
            settings.curFilters = $.grep settings.curFilters, (el, index) -> el.column isnt filterObj.column
            if settings.curFilters.length isnt 0
              body.find("tr").filter(":hidden").filter((i) ->
                match = false
                row = $ this
                $.each settings.curFilters, (index, item) -> match = $.trim(row.find("td:nth-child(#{item.column})").text()) is $.trim(item.value)
                match
              ).show()
            else body.find("tr").filter(":hidden").show()
            rebuild 0
            sBox.show()
          clearLink.clone(true).appendTo sBox.parent()
          rebuild 0

      buildSelect col
    table
) jQuery

