$(function() {
    $('.jquery-datepicker').datepicker({dateFormat: 'yy-mm-dd'});

    // Evaluation form validation for new students in 1st grade or above (non-EC classes)
    $('#continue-button').click(function(e) {
        var hasError = false;
        var errorStudents = [];

        $('.register-checkbox:checked').each(function() {
            var studentId = $(this).attr('id').replace('_register', '');
            var evalCheckbox = $('#' + studentId + '_eval_form_confirmed');

            // If there's an eval checkbox for this student, check if class type is EC
            if (evalCheckbox.length) {
                // Check the selected class type (could be dropdown or hidden field)
                var classTypeSelect = $('select[name="' + studentId + '_school_class_type"]');
                var classTypeHidden = $('input[name="' + studentId + '_school_class_type"]');
                var selectedClassType = '';

                if (classTypeSelect.length) {
                    selectedClassType = classTypeSelect.val();
                } else if (classTypeHidden.length) {
                    selectedClassType = classTypeHidden.val();
                }

                // Only require checkbox if class type is NOT EC
                if (selectedClassType !== 'EC' && !evalCheckbox.is(':checked')) {
                    hasError = true;
                    var studentName = $(this).closest('tr').find('td:nth-child(3)').text().trim();
                    errorStudents.push(studentName);
                }
            }
        });

        if (hasError) {
            e.preventDefault();
            alert('Please confirm that the following students have completed the evaluation form:\n\n' + errorStudents.join('\n') + '\n\nEvaluation form link: https://docs.google.com/forms/d/e/1FAIpQLSf5al9yGyBJCWLdezVzIUqe8uZwQVCemjJT2zdiUb0TIbdOjQ/viewform');
        }
    });
});

function registrationSelectGrade(selectElement, url, studentId, schoolYearId) {
    var jSelectElement = $(selectElement);
    var selectedGradeId = jSelectElement.children('option:selected').attr('value');
    jSelectElement.attr("disabled", true);
    var jTableElement = jSelectElement.parent().parent().parent();
    //jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_grade_id : selectedGradeId, student_id : studentId, school_year_id : schoolYearId}, function(data) {
        jTableElement.html(data);
    });
}

function registrationSelectClass(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedClassId = jSelectElement.children('option:selected').attr('value');
    jSelectElement.attr("disabled", true);
    var jTableElement = jSelectElement.parent().parent().parent();
    //jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_class_id : selectedClassId}, function(data) {
        setTableDataAndWireUpJQueryUi(jTableElement, data);
    });
}

function selectAssignmentDate(textFieldElement, url) {
    var jTextFieldElement = $(textFieldElement);
    var selectedDateString = jTextFieldElement.attr('value');
    var jTableElement = jTextFieldElement.parent().parent().parent();
    //jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_date_string : selectedDateString}, function(data) {
        setTableDataAndWireUpJQueryUi(jTableElement, data);
    });
}

function selectInstructorRole(selectElement, url) {
    var jSelectElement = $(selectElement);
    var selectedRole = jSelectElement.children('option:selected').attr('value');
    jSelectElement.attr("disabled", true);
    var jTableElement = jSelectElement.parent().parent().parent();
    //jTableElement.effect('highlight', {}, 2000);
    $.post(url, {selected_role : selectedRole}, function(data) {
        setTableDataAndWireUpJQueryUi(jTableElement, data);
    });
}

function removeInstructorAssignment(button, url) {
    var jButtonElement = $(button);
    jButtonElement.attr("disabled", true);
    var jTableElement = jButtonElement.parent().parent().parent();
    //jTableElement.effect('highlight', {}, 2000);
    $.post(url, function(data) {
        if (data == "destroy_successful") {
            jTableElement.remove();
        }
    });
}

function toggleSchoolClassActive(button, url, activeFlag, schoolYearId) {
    var jButtonElement = $(button);
    jButtonElement.attr("disabled", true);
    var jRowElement = jButtonElement.parent().parent();
    //jRowElement.effect('highlight', {}, 2000);
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
