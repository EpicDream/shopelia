window.ParsleyConfig = window.ParsleyConfig || {};

(function ($) {
    window.ParsleyConfig = $.extend( true, {}, window.ParsleyConfig, {
        messages: {
            // parsley //////////////////////////////////////
            defaultMessage: "Cette valeur semble non valide."
            , type: {
                email:      "Cette valeur n'est pas une adresse email valide."
                , url:        "Cette valeur n'est pas une URL valide."
                , urlstrict:  "Cette valeur n'est pas une URL valide."
                , number:     "Cette valeur doit ?tre un nombre."
                , digits:     "Cette valeur doit ?tre num?rique."
                , dateIso:    "Cette valeur n'est pas une date valide (YYYY-MM-DD)."
                , alphanum:   "Cette valeur doit ?tre alphanum?rique."
            }
            , notnull:        "Cette valeur ne peut pas ?tre nulle."
            , notblank:       "Cette valeur ne peut pas ?tre vide."
            , required:       "Ce champ est requis."
            , regexp:         "Cette valeur semble non valide."
            , min:            "Cette valeur ne doit pas ?tre inf?reure ? %s."
            , max:            "Cette valeur ne doit pas exc?der %s."
            , range:          "Cette valeur doit ?tre comprise entre %s et %s."
            , minlength:      "Cette cha?ne est trop courte. Elle doit avoir au minimum %s caract?res."
            , maxlength:      "Cette cha?ne est trop longue. Elle doit avoir au maximum %s caract?res."
            , rangelength:    "Cette valeur doit contenir entre %s et %s caract?res."
            , equalto:        "Cette valeur devrait ?tre identique."
            , mincheck:       "Vous devez s?lectionner au moins %s choix."
            , maxcheck:       "Vous devez s?lectionner %s choix maximum."
            , rangecheck:     "Vous devez s?lectionner entre %s et %s choix."

            // parsley.extend ///////////////////////////////
            , minwords:       "Cette valeur doit contenir plus de %s mots."
            , maxwords:       "Cette valeur ne peut pas d?passer %s mots."
            , rangewords:     "Cette valeur doit comprendre %s ? %s mots."
            , greaterthan:    "Cette valeur doit ?tre plus grande que %s."
            , lessthan:       "Cette valeur doit ?tre plus petite que %s."
        }
    });
}(window.jQuery || window.Zepto));