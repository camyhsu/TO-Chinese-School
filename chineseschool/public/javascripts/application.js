// The following adds CCRF authentication token to ajax post
// This requires the setup of AUTH_TOKEN in the header section (in layout, see app/views/layouts/_html_head_section.html.erb)
// This code is a combination of the great contributions from:
// http://henrik.nyh.se/2008/05/rails-authenticity-token-with-jquery
// http://pastie.org/212866
// http://www.viget.com/extend/ie-jquery-rails-and-http-oh-my
//

(function($) {
    $().ajaxSend(function(event, request, settings) {
        if (settings.type == 'GET' || settings.type == 'get' || typeof(AUTH_TOKEN) == "undefined") return;
        //request.setRequestHeader("Accept", "text/javascript, text/html, application/xml, text/xml, */*");
        request.setRequestHeader("Content-Type", "application/x-www-form-urlencoded");
        settings.data = settings.data || "";
        settings.data += ((settings.data == "") ? "" : "&") + "authenticity_token=" + encodeURIComponent(AUTH_TOKEN);
    });
})(jQuery);


$(document).ready(function() {
    $(".button").button();

});