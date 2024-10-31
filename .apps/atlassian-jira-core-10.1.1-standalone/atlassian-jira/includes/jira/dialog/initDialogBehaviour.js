define('jira/dialog/init-dialog-behaviour', ['jira/dialog/dialog-register', 'jira/dialog/dialog2', 'jira/issue', 'jira/issuenavigator/issue-navigator', 'jquery', 'underscore', 'exports'], function (DialogRegister, Dialog2, Issue, IssueNavigator, jQuery, _, exports) {
  'use strict';

  exports.init = function () {
    // JRA-32003 Ensure the dialogs are repositioned/resized if the window dimensions change
    jQuery(window).resize(_.debounce(function () {
      Dialog2.current && Dialog2.current._positionInCenter && Dialog2.current._positionInCenter();
    }, 200));

    // Dialogs should only show up if there's an issue to work on!
    jQuery.each(DialogRegister, function (name, dialog) {
      if (dialog instanceof Dialog2 && _.result(dialog, "isIssueDialog")) {
        jQuery(dialog).bind("beforeShow", function () {
          //Issue.getIssueId() can return either undefined or null depending on implementation.
          //Seems that the issue-search plugin overrides jira-core behaviour here (undefined) and
          //returns a different value (null) to indicate there's no issueId.
          return IssueNavigator.isRowSelected() || !!Issue.getIssueId();
        });
      }
    });
  };
});