
function selectProgram(checkboxElement, studentId, url) {
    var jCheckboxElement = $(checkboxElement);
    var selectedProgramId = jCheckboxElement.attr('value');
    var jRowElement = jCheckboxElement.parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, {student_id : studentId, selected_program_id : selectedProgramId}, function(data) {
        jRowElement.html(data);
    });
}
