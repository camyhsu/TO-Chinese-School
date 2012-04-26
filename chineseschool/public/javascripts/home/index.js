
function displayRoomParentSelection(buttonElement, url) {
    alert(url);
    var jButtonElement = $(buttonElement);
    var jSpanElement = jButtonElement.parent();
    jSpanElement.effect('highlight', {}, 2000);
    $.get(url, function(data) {
        jSpanElement.html(data);
    });
}
