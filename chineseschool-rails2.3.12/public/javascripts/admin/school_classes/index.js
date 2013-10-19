
function toggleActive(button, url, activeFlag, schoolYearId) {
    var jRowElement = $(button).parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, {active : activeFlag, school_year_id : schoolYearId}, function(data) {
        jRowElement.html(data);
    });
}
