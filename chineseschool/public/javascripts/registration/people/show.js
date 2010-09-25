$(function() {
    $('.jquery-datepicker').datepicker({dateFormat: 'yy-mm-dd'});
});

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
        setTableDataAndWireUpDatePicker(jTableElement, data);
    });
}

function selectAssignmentDate(textFieldElement, url) {
    var jTextFieldElement = $(textFieldElement);
    var selectedDateString = jTextFieldElement.attr('value');
    var jTableElement = jTextFieldElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_date_string : selectedDateString}, function(data) {
        setTableDataAndWireUpDatePicker(jTableElement, data);
    });
}

function selectRole(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedRole = jSelectElement.children('option:selected').attr('value');
    var jTableElement = jSelectElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_role : selectedRole}, function(data) {
        setTableDataAndWireUpDatePicker(jTableElement, data);
    });
}

function setTableDataAndWireUpDatePicker(jTableElement, data) {
    jTableElement.html(data);
    jTableElement.find('.jquery-datepicker').datepicker({dateFormat: 'yy-mm-dd'});
}
