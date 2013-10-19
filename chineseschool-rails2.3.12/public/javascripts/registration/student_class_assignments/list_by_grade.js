
function selectClass(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedClassId = jSelectElement.children('option:selected').attr('value');
    var jRowElement = jSelectElement.parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, {selected_class_id : selectedClassId}, function(data) {
        jRowElement.html(data);
    });
}

function removeFromGrade(button, url) {
    var jRowElement = $(button).parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, function(data) {
        if (data == "destroy_successful") {
            window.jQueryDataTable.fnDeleteRow(jRowElement[0]);
        }
    });
}
