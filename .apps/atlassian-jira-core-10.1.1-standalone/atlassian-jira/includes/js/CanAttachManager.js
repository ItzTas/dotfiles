define('jira/attachments/can-attach-manager', ['jquery', 'exports', 'wrm/context-path'], function ($, exports, wrmContextPath) {
  'use strict';

  exports.canAttach = function (projectKey) {
    return new Promise(function (resolve) {
      if (!projectKey) {
        resolve(false);
      } else {
        $.ajax({
          url: wrmContextPath() + '/rest/internal/2/attachment-permission/attach?projectKey=' + encodeURIComponent(projectKey),
          type: 'GET',
          dataType: 'json',
          success: function success(result) {
            resolve(result);
          },
          error: function error() {
            resolve(false);
          }
        });
      }
    });
  };
});