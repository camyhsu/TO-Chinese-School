
function selectProgram(checkboxElement, studentId, url) {
    var jCheckboxElement = $(checkboxElement);
    var programId = jCheckboxElement.attr('value');
    var checkedFlag = jCheckboxElement.attr('checked');
    var jRowElement = jCheckboxElement.parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, {student_id : studentId, program_id : programId, checked_flag : checkedFlag}, function(data) {
        jRowElement.html(data);
    });
}
