$(document).on("ready", function(){

    $.datepicker.setDefaults({dateFormat: 'yy-mm-dd'});
    $(document).ready(function() { jQuery(".best_in_place").best_in_place() });

    $('.best_in_place').bind("ajax:success", function () { $(this).closest('tr').children().effect('highlight', {color: "#91ee58"}, 'slow') });
    $('.best_in_place').bind("ajax:error", function () { $(this).closest('tr').children().effect('highlight', {color: "#ff552b"}, 'slow') });


    function doMultiple(obj, path, f){
        var type = $(obj).data("type");
        var myElements = document.querySelectorAll(".is-selected");
        for (var i = 0; i < myElements.length; i++) {
            var elem = myElements[i];
            var eventId = $(elem).data("event");
            var itemId = $(elem).data(type);
            var url = '/admins/events/' + eventId + '/' + type + 's/' + itemId + '/' + path ;

            $.ajax  ({
                type: "POST",
                url: url,
                dataType: "json",
                async: false,
                success: f(elem)
            });

        }
    }

    $("#hide_multiple").on("click",function(event){
        doMultiple(this, "hide", function(elem) {
            $(elem).addClass("resource-hidden");
            $(elem).find(".no_switch").addClass("is-checked no_switch").addClass("yes_switch");
        })
    });

    $("#unhide_multiple").on("click",function(event){
        doMultiple(this, "hide", function(elem) {
            $(elem).removeClass("resource-hidden");
            $(elem).find(".yes_switch").removeClass("is-checked yes_switch").addClass("no_switch");
        });
    });

});

