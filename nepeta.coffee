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
      select = $ "<select/>", {class: "filter"}
      col = ":nth-child(#{curCol})"
      firstRun = true
      
      
      unfiltered = (cCol) ->
        flag = true
        $.each settings.curFilters, (index, item) ->
           flag = item.column isnt cCol
        flag
 
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
        head.find("tr>*#{selector}").each ->
          selectBox = box.clone true
          $(this).append selectBox

      rebuild = (x) ->
        $.each $("select.filter").filter(":visible"), (index, item) ->
          console.log this
          buildSelect ":nth-child(#{$(item).attr("class").replace(/\D/g,"")})"
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
          clearLink = $ "<a>", { text: "(#{if $.trim(chk) isnt "" then $.trim chk else "None"})" }
          clearLink.css {display: "block"}
          clearLink.click ->
            $(this).remove()
            sBox.prop "selectedIndex", 0
            popFilter = settings.curFilters.splice settings.curFilters.indexOf({column: cColumn, value: chk}), 1
            if settings.curFilters.length isnt 0
              body.find("tr").filter(":hidden").filter((i) ->
                match = false
                row = $ this
                $.each settings.curFilters, (index, item) ->
                  match = $.trim(row.find("td:nth-child(#{item.column})").text()) is $.trim(item.value)
                match
              ).show()
            else body.find("tr").filter(":hidden").show()
            rebuild 0
            sBox.show()
          clearLink.appendTo sBox.parent()
          rebuild 0

      buildSelect col
    this
) jQuery

