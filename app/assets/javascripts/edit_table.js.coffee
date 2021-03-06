class @EditTable
  @build: (selector, opts={}) ->
    $(selector).map (i, e) ->
      table = new EditTable(e, opts)
      table.bindActions()
      table

  constructor: (selector, opts) ->
    @form  = $(selector)
    @table = @form.find("table")
    @applyErrorValuesCallback = opts.applyErrorValuesCallback

    @hiddenRow = null
    @initialAction = @form.attr("action")
    @errorPayload  = @table.data("error-payload")

    if @errorPayload
      row = $("\##{@table.data("id-prefix")}_#{@errorPayload.id}")
      @openEditRow(row)
      @applyErrorValues(row, @errorPayload)

  # Lookups
  hiddenFormMethod: (method) ->
    $("<input name=\"_method\" type=\"hidden\" value=\"#{method}\">")

  headerFieldsRow: () ->
    @form.find("table thead tr")

  relatedRow: (el) ->
    idFromRel = $(el).attr("rel")
    $("#"+idFromRel)

  # Helpers
  disableFields: (el) ->
    $(el).find("input,select").each () ->
      $(this).attr("readonly", true).attr("disabled", true)

  enableFields: (el) ->
    $(el).find("input,select").each () ->
      $(this).removeAttr("readonly").removeAttr("disabled")

  setFormActionAndMethod: (action, method) ->
    @form.attr("action", action)

    if method.toLowerCase() != "get" && method.toLowerCase() != "post"
      @form.append(@hiddenFormMethod(method))
    else
      @form.children("[name=_method]").remove()

  restoreOriginalValues: (fieldsRow) ->
    $(fieldsRow).find("input").each ->
      field = $(this)
      field.val(field.attr("value"))

    $(fieldsRow).find("select").each ->
      field = $(this)
      field.val(field.find('option[selected=selected]').attr('value'))

  applyErrorValues: (el, data) ->
    fieldsRow = @relatedRow(el)

    $.each data, (item) =>
      field = $(fieldsRow).find($("input[name$='[#{item}]']"))
      $(field).val(data[item])

      # Apply Any Client-side formatting for fields
      if field.hasClass("datepicker") || field.hasClass('alt-datepicker')
        DatePicker.setup(field)

      if field.length && @applyErrorValuesCallback
        @applyErrorValuesCallback(field)

  # Main actions
  openEditRow: ($row) ->
    @closeEditRow(@form.find('.editing'), false)

    action = $row.data("form-url")
    @setFormActionAndMethod(action, "put")

    @disableFields(@headerFieldsRow())
    @enableFields($row)

    $row.addClass('editing')
    @form.find('.add-toggle').addClass('is-hidden')
    $('.form-actions .btn--save, .form-actions input[type=submit]').prop('disabled', 'disabled').addClass('disabled').on 'click', (e) ->
      e.preventDefault()
    $row.parents('.table-wrapper').trigger "scroll"

  openAddRow: () ->
    @closeEditRow(@form.find('.editing'), false)

    fieldsRow = @form.find(".add-row")
    fieldsRow.removeClass('is-hidden').addClass('editing')
    @enableFields(fieldsRow)

    @form.find('.add-toggle').addClass('is-hidden')
    $('.form-actions .btn--save, .form-actions input[type=submit]').prop('disabled', 'disabled').addClass('disabled').on 'click', (e) ->
      e.preventDefault()
    fieldsRow.parents('.table-wrapper').trigger "scroll"

  copyOpenAddRow: () ->
    selected = @form.find('.add-row select').val()

    fieldsRow = @form.find('.add-row').clone(false)
    fieldsRow.removeClass().removeAttr('id')
    fieldsRow.children().removeClass().addClass('field')
    fieldsRow.children().last().html('')
    fieldsRow.find('.chosen-container').remove()
    fieldsRow.find('select').data('chosen', undefined).removeAttr('style').removeAttr('id')
    fieldsRow.find("select option[value=#{selected}]").attr('selected', 'selected')
    @enableFields(fieldsRow)

    fieldsRow.insertBefore(@form.find('.add-row'))

    fieldsRow.find('select').chosen({
      search_contains: true
      group_search: true
      enable_split_word_search: true
      allow_single_deselect: true
      no_results_text: 'No results matched'
      width: '100%'
    })

  closeEditRow: ($row, cancel) ->
    return if $row.length == 0

    @disableFields($row)
    $row.removeClass('editing')
    if $row.hasClass('add-row')
      $row.addClass('is-hidden')
    $row.parents('.table-wrapper').first().scrollLeft(0)
    $row.parents('.table-wrapper').trigger "scroll"

    @form.find(".add-toggle").removeClass('is-hidden')
    $('.form-actions .btn--save, .form-actions input[type=submit]').prop('disabled', null).removeClass('disabled').off 'click'

    @restoreOriginalValues($row) if cancel

    @enableFields(@headerFieldsRow())

    @setFormActionAndMethod(@initialAction, "post")

    @hiddenRow.show() if @hiddenRow != null
    @hiddenRow = null

  clearAndCloseEditRow: ($row) ->
    chosen = @form.find('.add-row select.chosen').data('chosen')
    if chosen
      chosen.results_reset()

    @form.find(".add-row #product_sibling_unit_id").val("")
    @form.find(".add-row #product_sibling_unit_description").val("")

    @closeEditRow($row, true)

  bindActions: () ->
    context = this
    @form.on "click", ".edit-trigger", (e) ->
      e.preventDefault()
      context.openEditRow($(this).parents("tr"))

    @form.on "click", "tr .cancel", (e) ->
      e.preventDefault()
      context.clearAndCloseEditRow($(this).parents("tr"))

    @form.on "click", ".add-toggle", (e) ->
      e.preventDefault()
      $(this).addClass('is-hidden')
      context.openAddRow()

    @form.on "click", ".add-copy", (e) ->
      e.preventDefault()
      context.copyOpenAddRow()
      context.clearAndCloseEditRow($(this).parents("tr"))

    @form.on "click", ".delete-selected", (e) ->
      e.preventDefault()
      context.setFormActionAndMethod(@initialAction, "delete")
      context.form.submit()

    @form.on "click", ".select-all", (e) ->
      checked = $(this).prop('checked')
      context.form.find('td:first-child input').prop('checked', checked).trigger('change')

    @form.on "change", "td:first-child input", (e) ->
      if $(this).prop('checked')
        context.form.find('.delete-selected').removeClass('is-invisible')
      else
        context.form.find('.delete-selected').addClass('is-invisible')
