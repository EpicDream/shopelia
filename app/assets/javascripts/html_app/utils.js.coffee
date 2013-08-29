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
  #console.log(validator)
  result = validator.formatMesssage(validator.messages[constraint.name], constraint.requirements)
  if result == ""
    result = validator.messages[constraint.name]
  unless 'string' == typeof result
    result = result[constraint.requirements]
  result

window.countries =
{
"AF":"Afghanistan",
"AX":"Åland Islands"
"AL":"Albania",
"DZ":"Algeria",
"AS":"American Samoa",
"AD":"Andorra",
"AO":"Angola",
"AI":"Anguilla",
"AQ":"Antarctica",
"AG":"Antigua and Barbuda",
"AR":"Argentina",
"AM":"Armenia",
"AW":"Aruba",
"AU":"Australia",
"AT":"Austria",
"AZ":"Azerbaijan",
"BS":"Bahamas",
"BH":"Bahrain",
"BD":"Bangladesh",
"BB":"Barbados",
"BY":"Belarus",
"BE":"Belgique",
"BZ":"Belize",
"BJ":"Benin",
"BM":"Bermuda",
"BT":"Bhutan",
"BO":"Bolivia",
"BA":"Bosnia and Herzegovina",
"BW":"Botswana",
"BV":"Bouvet Island",
"BR":"Brazil",
"IO":"British Indian Ocean Territory",
"BN":"Brunei Darussalam",
"BG":"Bulgaria",
"BF":"Burkina Faso",
"BI":"Burundi",
"KH":"Cambodia",
"CM":"Cameroon",
"CA":"Canada",
"CV":"Cape Verde",
"KY":"Cayman Islands",
"CF":"Central African Republic",
"TD":"Chad",
"CL":"Chile",
"CN":"China",
"CX":"Christmas Island",
"CC":"Cocos (Keeling) Islands",
"CO":"Colombia",
"KM":"Comoros",
"CG":"Congo",
"CD":"Congo, The Democratic Republic of The",
"CK":"Cook Islands",
"CR":"Costa Rica",
"CI":"Cote D'ivoire",
"HR":"Croatia",
"CU":"Cuba",
"CY":"Cyprus",
"CZ":"Czech Republic",
"DK":"Denmark",
"DJ":"Djibouti",
"DM":"Dominica",
"DO":"Dominican Republic",
"EC":"Ecuador",
"EG":"Egypt",
"SV":"El Salvador",
"GQ":"Equatorial Guinea",
"ER":"Eritrea",
"EE":"Estonia",
"ET":"Ethiopia",
"FK":"Falkland Islands (Malvinas)",
"FO":"Faroe Islands",
"FJ":"Fiji",
"FI":"Finland",
"FR":"France",
"GF":"French Guiana",
"PF":"French Polynesia",
"TF":"French Southern Territories",
"GA":"Gabon",
"GM":"Gambia",
"GE":"Georgia",
"DE":"Germany",
"GH":"Ghana",
"GI":"Gibraltar",
"GR":"Greece",
"GL":"Greenland",
"GD":"Grenada",
"GP":"Guadeloupe",
"GU":"Guam",
"GT":"Guatemala",
"GG":"Guernsey",
"GN":"Guinea",
"GW":"Guinea-bissau",
"GY":"Guyana",
"HT":"Haiti",
"HM":"Heard Island and Mcdonald Islands",
"VA":"Holy See (Vatican City State)",
"HN":"Honduras",
"HK":"Hong Kong",
"HU":"Hungary",
"IS":"Iceland",
"IN":"India",
"ID":"Indonesia",
"IR":"Iran, Islamic Republic of",
"IQ":"Iraq",
"IE":"Ireland",
"IM":"Isle of Man",
"IL":"Israel",
"IT":"Italy",
"JM":"Jamaica",
"JP":"Japan",
"JE":"Jersey",
"JO":"Jordan",
"KZ":"Kazakhstan",
"KE":"Kenya",
"KI":"Kiribati",
"KP":"Korea, Democratic People's Republic of",
"KR":"Korea, Republic of",
"KW":"Kuwait",
"KG":"Kyrgyzstan",
"LA":"Lao People's Democratic Republic",
"LV":"Latvia",
"LB":"Lebanon",
"LS":"Lesotho",
"LR":"Liberia",
"LY":"Libyan Arab Jamahiriya",
"LI":"Liechtenstein",
"LT":"Lithuania",
"LU":"Luxembourg",
"MO":"Macao",
"MK":"Macedonia, The Former Yugoslav Republic of",
"MG":"Madagascar",
"MW":"Malawi",
"MY":"Malaysia",
"MV":"Maldives",
"ML":"Mali",
"MT":"Malta",
"MH":"Marshall Islands",
"MQ":"Martinique",
"MR":"Mauritania",
"MU":"Mauritius",
"YT":"Mayotte",
"MX":"Mexico",
"FM":"Micronesia, Federated States of",
"MD":"Moldova, Republic of",
"MC":"Monaco",
"MN":"Mongolia",
"ME":"Montenegro",
"MS":"Montserrat",
"MA":"Morocco",
"MZ":"Mozambique",
"MM":"Myanmar",
"NA":"Namibia",
"NR":"Nauru",
"NP":"Nepal",
"NL":"Netherlands",
"AN":"Netherlands Antilles",
"NC":"New Caledonia",
"NZ":"New Zealand",
"NI":"Nicaragua",
"NE":"Niger",
"NG":"Nigeria",
"NU":"Niue",
"NF":"Norfolk Island",
"MP":"Northern Mariana Islands",
"NO":"Norway",
"OM":"Oman",
"PK":"Pakistan",
"PW":"Palau",
"PS":"Palestinian Territory, Occupied",
"PA":"Panama",
"PG":"Papua New Guinea",
"PY":"Paraguay",
"PE":"Peru",
"PH":"Philippines",
"PN":"Pitcairn",
"PL":"Poland",
"PT":"Portugal",
"PR":"Puerto Rico",
"QA":"Qatar",
"RE":"Reunion",
"RO":"Romania",
"RU":"Russian Federation",
"RW":"Rwanda",
"SH":"Saint Helena",
"KN":"Saint Kitts and Nevis",
"LC":"Saint Lucia",
"PM":"Saint Pierre and Miquelon",
"VC":"Saint Vincent and The Grenadines",
"WS":"Samoa",
"SM":"San Marino",
"ST":"Sao Tome and Principe",
"SA":"Saudi Arabia",
"SN":"Senegal",
"RS":"Serbia",
"SC":"Seychelles",
"SL":"Sierra Leone",
"SG":"Singapore",
"SK":"Slovakia",
"SI":"Slovenia",
"SB":"Solomon Islands",
"SO":"Somalia",
"ZA":"South Africa",
"GS":"South Georgia and The South Sandwich Islands",
"ES":"Spain",
"LK":"Sri Lanka",
"SD":"Sudan",
"SR":"Suriname",
"SJ":"Svalbard and Jan Mayen",
"SZ":"Swaziland",
"SE":"Sweden",
"CH":"Switzerland",
"SY":"Syrian Arab Republic",
"TW":"Taiwan, Province of China",
"TJ":"Tajikistan",
"TZ":"Tanzania, United Republic of",
"TH":"Thailand",
"TL":"Timor-leste",
"TG":"Togo",
"TK":"Tokelau",
"TO":"Tonga",
"TT":"Trinidad and Tobago",
"TN":"Tunisia",
"TR":"Turkey",
"TM":"Turkmenistan",
"TC":"Turks and Caicos Islands",
"TV":"Tuvalu",
"UG":"Uganda",
"UA":"Ukraine",
"AE":"United Arab Emirates",
"GB":"United Kingdom",
"US":"United States",
"UM":"United States Minor Outlying Islands",
"UY":"Uruguay",
"UZ":"Uzbekistan",
"VU":"Vanuatu",
"VE":"Venezuela",
"VN":"Viet Nam",
"VG":"Virgin Islands, British",
"VI":"Virgin Islands, U.S.",
"WF":"Wallis and Futuna",
"EH":"Western Sahara",
"YE":"Yemen",
"ZM":"Zambia",
"ZW":"Zimbabwe"
}