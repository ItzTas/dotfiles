define('jira/field/user-picker-util', ['jira/ajs/list/item-descriptor', 'jira/ajs/list/group-descriptor', 'wrm/context-path', 'jquery', 'underscore'], function (ItemDescriptor, GroupDescriptor, contextPath, jQuery, _) {
  'use strict';

  var urls = {
    reporter: '/rest/internal/2/users/reporter'
  };
  var getHTML = function getHTML(user, query) {
    var regexMatchingFromBeginningOfTheWord = new RegExp("\\b".concat(RegExp.escape(query)), 'ig');
    var highlightQuery = function highlightQuery(value) {
      return value.replace(regexMatchingFromBeginningOfTheWord, function (match) {
        return "<mark>".concat(match, "</mark>");
      });
    };

    // Users can set malicious HTML in their display names, so we need to escape it
    var escapedDisplayName = _.escape(user.displayName);
    // Also, historically, there were different validation rules for other user fields too, so it's better to be safe than sorry with those too.
    var escapedUserName = _.escape(user.name);
    var escapedEmailAddress = _.escape(user.emailAddress);
    return "".concat(highlightQuery(escapedDisplayName)).concat(user.emailAddress ? " - ".concat(escapedEmailAddress) : '', " (").concat(highlightQuery(escapedUserName), ")");
  };
  var userPickerUtil = {
    getUrl: function getUrl(isCustomField, useNewEndpoint, userPickerName) {
      if (useNewEndpoint) {
        if (!urls[userPickerName]) {
          throw new Error("The URL for the ".concat(userPickerName, " picker is not defined"));
        }
        return "".concat(contextPath()).concat(urls[userPickerName]);
      }
      return "".concat(contextPath()).concat(isCustomField ? '/rest/api/1.0/users/picker' : '/rest/api/2/user/picker');
    },
    formatResponse: function formatResponse(data) {
      var ret = [];
      jQuery(data).each(function (i, suggestions) {
        var groupDescriptor = new GroupDescriptor({
          weight: i,
          // order or groups in suggestions dropdown
          label: suggestions.footer
        });
        jQuery(suggestions.users).each(function () {
          groupDescriptor.addItem(new ItemDescriptor({
            value: this.name,
            // value of item added to select
            label: this.displayName,
            html: this.html,
            icon: this.avatarUrl,
            iconType: 'rounded',
            allowDuplicate: false,
            highlighted: true,
            userKey: this.key
          }));
        });
        ret.push(groupDescriptor);
      });
      return ret;
    },
    formatResponseWithoutHTML: function formatResponseWithoutHTML(data, query) {
      var dataWithHTML = {
        users: data.users.map(function (user) {
          user.html = getHTML(user, query);
          return user;
        })
      };
      return userPickerUtil.formatResponse(dataWithHTML, query, false);
    }
  };
  return userPickerUtil;
});
AJS.namespace('JIRA.UserPickerUtil', null, require('jira/field/user-picker-util'));