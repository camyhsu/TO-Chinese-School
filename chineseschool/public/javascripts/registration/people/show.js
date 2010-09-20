
function selectGrade(selectElement, url, studentId) {
    var jSelectElement = $(selectElement);
    var selectedGradeId = jSelectElement.children('option:selected').attr('value');
    var jTableElement = jSelectElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
        $.post(url, {selected_grade_id : selectedGradeId, student_id : studentId}, function(data) {
        jTableElement.html(data);
    });
}

function selectClass(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedClassId = jSelectElement.children('option:selected').attr('value');
    var jTableElement = jSelectElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_class_id : selectedClassId}, function(data) {
        jTableElement.html(data);
    });
}

function selectRole(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedRole = jSelectElement.children('option:selected').attr('value');
    var jTableElement = jSelectElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_role : selectedRole}, function(data) {
        jTableElement.html(data);
    });
}
