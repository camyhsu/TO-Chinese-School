
function toggleActive(button, url) {
    var jRowElement = $(button).parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, function(data) {
        jRowElement.html(data);
    });
}
