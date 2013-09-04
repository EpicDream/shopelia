String.prototype.capitalize = ->
  this.charAt(0).toUpperCase() + this.slice(1)

String.prototype.uncapitalize = ->
  this.charAt(0).toLowerCase() + this.slice(1)

String.prototype.normalizeName = ->
  names = this.split('_')
  res = ''
  _.each(names,(name) ->
      res += name.capitalize()
    )
  res

window.formatCurrency = (price) ->
  parseFloat(Math.round(price * 100) / 100).toFixed(2) + "&nbsp;€"

window.formatShipping = (value) ->
  unless isNaN(value)
    if parseFloat(value) isnt 0
      '<p>frais de livraison <span class="green">' + window.formatCurrency(value) + '</span></p>'
    else
      '<span class="green">Livraison gratuite</span>'

window.eraseErrors =  ->
  $(".control-group").removeClass('error')
  $('.help-inline').remove()

window.disableButton = ($button) ->
  $button.attr('disabled','disabled')
  $button.addClass('disabled')

window.enableButton = ($button) ->
  $button.removeAttr('disabled','disabled')
  $button.removeClass('disabled')

window.displayErrors = (errors) ->
  keys = _.keys(errors)
  $errors = $('<ul/>')
  _.each(keys,(key) ->
    console.log($errors.html())
    $errors.append("<li>" + errors[key] + "</li>")
    if  (key == "first_name" || key == "last_name")
      errorField =  $("input[name=full_name]")
    else if key == "error" && errors[key] == "Email ou mot de passe incorrect."
      errorField = $("input[name=email]")
      passwordField = $("input[name=password]")
      passwordField.parents(".control-group").removeClass('success')
      passwordField.parents(".control-group").addClass('error')
      passwordField.popover({
                       'trigger' : 'focus',
                       'placement': 'top',
                       'content': errors[key]
                       })
    else
      errorField =  $("input[name=" + key + "]")

    errorField.parents(".control-group").removeClass('success')
    errorField.parents(".control-group").addClass('error')
    errorField.popover({
                       'trigger' : 'focus',
                       'placement': 'top',
                       'content': errors[key]
                       })
  )
  Shopelia.Notification.Error({title: "Erreurs", text: " "+ $errors.html() + " "})

window.split =  (fullName) ->
  firstName =  fullName.substr(0,fullName.indexOf(' '))
  lastName =  fullName.substr(fullName.indexOf(' ')+1)
  if firstName == ''
    [lastName,'']
  else
    [firstName,lastName]

window.getMessageFromValidator = (validator,constraint) ->
  result = validator.formatMesssage(validator.messages[constraint.name], constraint.requirements)
  if result == ""
    result = validator.messages[constraint.name]
  unless 'string' == typeof result
    result = result[constraint.requirements]
  result

window.countries =
{
"AT":"Austria",
"BE":"Belgique",
"DK":"Denmark",
"FI":"Finland",
"FR":"France",
"DE":"Germany",
"IE":"Ireland",
"IT":"Italy",
"LI":"Liechtenstein",
"LU":"Luxembourg",
"MC":"Monaco",
"ES":"Spain",
"CH":"Suisse",
}