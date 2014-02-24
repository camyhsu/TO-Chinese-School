function displayRoomParentSelection(buttonElement, url) {
    var jButtonElement = $(buttonElement);
    jButtonElement.attr("disabled", true);
    var jSpanElement = jButtonElement.parent();
    //jSpanElement.effect('highlight', {}, 2000);
    $.get(url, function(data) {
        jSpanElement.html(data);
    });
}

function saveRoomParentSelection(buttonElement, url) {
    var jButtonElement = $(buttonElement);
    jButtonElement.attr("disabled", true);
    var jSpanElement = jButtonElement.parent();
    var jSelectElement = jSpanElement.children('select');
    var selectedRoomParentId = jSelectElement.children('option:selected').attr('value');
    //jSpanElement.effect('highlight', {}, 2000);
    $.post(url, {room_parent_id : selectedRoomParentId}, function(data) {
        jSpanElement.html(data);
    });
}
