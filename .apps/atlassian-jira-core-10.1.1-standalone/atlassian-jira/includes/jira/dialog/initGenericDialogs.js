define('jira/dialog/init-generic-dialogs', ['jira/dialog/dialog-register', 'jira/dialog/dialog-util', 'jira/dialog/form-dialog2', 'jira/ajs/keyboardshortcut/keyboard-shortcut-toggle', 'jquery', 'exports'], function (DialogRegister, DialogUtil, FormDialog2, KST, jQuery, exports) {
  "use strict";

  exports.init = function () {
    DialogRegister.keyboardShortcuts = new FormDialog2({
      id: "keyboard-shortcuts-dialog",
      trigger: "#keyshortscuthelp",
      widthClass: "large",
      onContentRefresh: function onContentRefresh() {
        var context = this.get$popup();
        jQuery("a.submit-link", context).click(function (e) {
          e.preventDefault();
          jQuery("form", context).submit();
        });
      },
      onSuccessfulSubmit: function onSuccessfulSubmit() {
        if (KST.areKeyboardShortcutsDisabled()) {
          KST.enable();
        } else {
          KST.disable();
        }
      },
      shouldFocusTitleOnLoad: true
    });
    DialogRegister.deleteIssueLink = new FormDialog2({
      type: "ajax",
      id: "delete-issue-link-dialog",
      trigger: "#linkingmodule .delete-link > a",
      ajaxOptions: DialogUtil.getDefaultAjaxOptions,
      isIssueDialog: true
    });
    new FormDialog2({
      id: "credits-dialog",
      trigger: "#view_credits",
      widthClass: "creditsContainer"
    });
    new FormDialog2({
      id: "about-dialog",
      trigger: "#view_about",
      ajaxOptions: {
        url: this.href,
        data: {
          decorator: "dialog",
          inline: true
        }
      },
      widthClass: "large"
    });
    jQuery(document).on("click", ".trigger-dialog", function (e) {
      e.preventDefault();
      var stacked = e.target !== undefined && jQuery(e.target).hasClass("stacked-dialog");
      var dialog = new FormDialog2({
        id: this.id + "-dialog",
        ajaxOptions: {
          url: this.href,
          data: {
            decorator: "dialog",
            inline: true
          }
        },
        stacked: stacked
      });
      dialog.show();
    });
  };
});