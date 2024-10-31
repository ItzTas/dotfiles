define('jira/viewissue/invoke-comment-trigger', ['jquery'], function ($) {
  'use strict';

  /**
   * Invoke the most appropriate comment trigger on page.
   * If the header toolbar trigger is present then invoke that.
   * Otherwise invoke the first link with ".add-issue-comment" class (needed for adding comments in Issue Nav list view).
   *
   * @note Used by keyboard shortcuts on the view issue page.
   *       Specifically, the 'm' keyboard shortcut.
   *
   */
  return function invokeCommentTrigger() {
    var addIssueComment = $(".add-issue-comment");
    if (addIssueComment.length === 0) {
      return;
    }
    var toolbarTrigger = addIssueComment.filter(".toolbar-trigger").get(0);
    var elementToClick = toolbarTrigger || addIssueComment.get(0);
    elementToClick.click();
  };
});
(function () {
  'use strict';

  var commentForm = require('jira/viewissue/comment/comment-form');
  AJS.namespace('JIRA.Issue.CommentForm', null, commentForm);
  AJS.namespace('JIRA.Issue.getDirtyCommentWarning', null, commentForm.handleBrowseAway);
  AJS.namespace('JIRA.Issue.invokeCommentTrigger', null, require('jira/viewissue/invoke-comment-trigger'));
})();