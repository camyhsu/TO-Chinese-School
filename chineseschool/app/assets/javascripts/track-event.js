function selectTrackProgram(checkboxElement, studentId, url) {
    var jCheckboxElement = $(checkboxElement);
    var programId = jCheckboxElement.attr('value');
    var checkedFlag = jCheckboxElement.is(':checked') ? 'true' : 'false';
    jCheckboxElement.attr("disabled", true);
    var jCellElement = jCheckboxElement.parent();
    //var jRowElement = jCellElement.parent();
    //jCellElement.css({'background-color':'#FFFF00'}).animate({'background-color':''}, 2000);
    $.post(url, {student_id : studentId, program_id : programId, checked_flag : checkedFlag}, function(data) {
        if (data.indexOf("Error:") == 0) {
            alert(data.slice(6));
            jCheckboxElement.attr('checked', false);
        } else {
            jCellElement.html(data);
        }
    });
}

function selectRelayGroup(selectElement, studentId, programId, url) {
    var jSelectElement = $(selectElement);
    var selectedRelayGroup = jSelectElement.children('option:selected').attr('value');
    jSelectElement.attr("disabled", true);
    var jCellElement = jSelectElement.parent();
    $.post(url, {student_id : studentId, program_id : programId, selected_relay_group : selectedRelayGroup}, function(data) {
        jCellElement.html(data);
    });
}

function selectTrackTeam(selectElement, genderValue, url) {
    var jSelectElement = $(selectElement);
    var selectedTrackTeamId = jSelectElement.children('option:selected').attr('value');
    jSelectElement.attr("disabled", true);
    var jCellElement = jSelectElement.parent();
    $.post(url, {selected_track_team_id : selectedTrackTeamId, gender : genderValue}, function(data) {
        jCellElement.html(data);
    });
}

function selectParent(checkboxElement, studentId, parentId, url) {
    var jCheckboxElement = $(checkboxElement);
    var programId = jCheckboxElement.attr('value');
    var checkedFlag = jCheckboxElement.is(':checked') ? 'true' : 'false';
    jCheckboxElement.attr("disabled", true);
    var jParentDivElement = jCheckboxElement.parent();
    $.post(url, {student_id : studentId, parent_id : parentId, program_id : programId, checked_flag : checkedFlag}, function(data) {
        jParentDivElement.html(data);
    });
}

function selectParentRelayGroup(selectElement, studentId, parentId, programId, url) {
    var jSelectElement = $(selectElement);
    var selectedRelayGroup = jSelectElement.children('option:selected').attr('value');
    jSelectElement.attr("disabled", true);
    var jParentDivElement = jSelectElement.parent();
    $.post(url, {student_id : studentId, parent_id : parentId, program_id : programId, selected_relay_group : selectedRelayGroup}, function(data) {
        jParentDivElement.html(data);
    });
}
