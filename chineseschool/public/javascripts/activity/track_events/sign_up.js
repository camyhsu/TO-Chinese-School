
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

function selectRelayGroup(selectElement, studentId, programId, url) {
    var jSelectElement = $(selectElement);
    var selectedRelayGroup = jSelectElement.children('option:selected').attr('value');
    var jRowElement = jSelectElement.parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, {student_id : studentId, program_id : programId, selected_relay_group : selectedRelayGroup}, function(data) {
        jRowElement.html(data);
    });
}

function selectParent(checkboxElement, studentId, parentId, url) {
    var jCheckboxElement = $(checkboxElement);
    var programId = jCheckboxElement.attr('value');
    var checkedFlag = jCheckboxElement.attr('checked');
    var jRowElement = jCheckboxElement.parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, {student_id : studentId, parent_id : parentId, program_id : programId, checked_flag : checkedFlag}, function(data) {
        jRowElement.html(data);
    });
}
