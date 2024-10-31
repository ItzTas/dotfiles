/**
 * The logic moved to `jira/api/version`.
 * @deprecated use {@link module:jira/api/version}
 */
define('jira/util/version', ['jira/api/version'], function (jiraVersion) {
  'use strict';

  return jiraVersion;
});
AJS.namespace('JIRA.Version', null, require('jira/util/version'));