$(function() {
    $('.jquery-datepicker').datepicker({dateFormat: 'yy-mm-dd'});
});

function registrationSelectGrade(selectElement, url, studentId) {
    var jSelectElement = $(selectElement);
    var selectedGradeId = jSelectElement.children('option:selected').attr('value');
    var jTableElement = jSelectElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_grade_id : selectedGradeId, student_id : studentId}, function(data) {
        jTableElement.html(data);
    });
}

function registrationSelectClass(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedClassId = jSelectElement.children('option:selected').attr('value');
    var jTableElement = jSelectElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_class_id : selectedClassId}, function(data) {
        setTableDataAndWireUpJQueryUi(jTableElement, data);
    });
}

function selectAssignmentDate(textFieldElement, url) {
    var jTextFieldElement = $(textFieldElement);
    var selectedDateString = jTextFieldElement.attr('value');
    var jTableElement = jTextFieldElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_date_string : selectedDateString}, function(data) {
        setTableDataAndWireUpJQueryUi(jTableElement, data);
    });
}

function selectInstructorRole(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedRole = jSelectElement.children('option:selected').attr('value');
    var jTableElement = jSelectElement.parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_role : selectedRole}, function(data) {
        setTableDataAndWireUpJQueryUi(jTableElement, data);
    });
}

function removeInstructorAssignment(button, url) {
    var jTableElement = $(button).parent().parent().parent();
    jTableElement.effect('highlight', {}, 2000);
    $.post(url, function(data) {
        if (data == "destroy_successful") {
            jTableElement.remove();
        }
    });
}

function toggleSchoolClassActive(button, url, activeFlag, schoolYearId) {
    var jRowElement = $(button).parent().parent();
    jRowElement.effect('highlight', {}, 2000);
    $.post(url, {active : activeFlag, school_year_id : schoolYearId}, function(data) {
        jRowElement.html(data);
    });
}

// Not called from HTML directly - used only by other scripts
function setTableDataAndWireUpJQueryUi(jTableElement, data) {
    jTableElement.html(data);
    jTableElement.find('.jquery-datepicker').datepicker({dateFormat: 'yy-mm-dd'});
    jTableElement.find('.button').button();
}
