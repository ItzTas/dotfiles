require(['jquery', 'jira/dialog/form-dialog2', 'jira/util/urls'], function ($, FormDialog2, urls) {
  'use strict';

  $(function () {
    // eslint-disable-line @atlassian/onready-checks/no-jquery-onready
    // JIRA.loggingLevels is made available via an inline script written to the page by a JSP.
    var loggingLevels = JIRA.loggingLevels;
    new FormDialog2({
      trigger: "#add-custom-logger-link",
      id: "add-custom-loger-dialog",
      width: 560,
      content: function content(ready) {
        var content = JIRA.Templates.Logging.loggerForm({
          availableLevels: loggingLevels,
          atlToken: urls.atl_token()
        });
        var $dialogWrapper = $(content);
        ready($dialogWrapper);
      },
      autoClose: true
    });
  });
});