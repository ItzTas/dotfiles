// A note: Non-deprecated modules should be extracted to separate files and be exposed via separate web-resources

/**
 * @deprecated Use AUI Dialog2 or Jira Dialog2
 */
define('aui/dialog', function() { return AJS.Dialog; });
/**
 * @deprecated Use AUI Dropdown 2
 */
define('aui/dropdown', function() { return AJS.dropDown; });
define('aui/message', function() { return AJS.messages; });
/**
 * @deprecated in AUI, to be removed in AUI 10
 */
define('aui/params', function() { return AJS.params; });
define('aui/progressive-data-set', function() { return AJS.ProgressiveDataSet; });
/**
 * @deprecated Use AUI Dialog2 or Jira Dialog2
 */
define('aui/popup', function() { return AJS.popup; });
define('aui/tabs', function() { return AJS.tabs; });

/**
 * @deprecated Use AUI InlineDialog2
 */
define('aui/inline-dialog', ['jira/ajs/layer/layer-interactions'], function(interactions) {
    'use strict';
    interactions.preventDialogHide(AJS.InlineDialog);
    interactions.hideBeforeDialogShown(AJS.InlineDialog);
    return AJS.InlineDialog;
});
