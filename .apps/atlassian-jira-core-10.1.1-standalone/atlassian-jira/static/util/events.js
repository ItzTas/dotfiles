/**
 * Utility functions for document-level event binding and handling.
 * @module jira/util/events
 * @see module:jira/util/events/reasons
 * @see module:jira/util/events/types
 *
 * The logic moved to {@link module:jira/api/events}.
 * @deprecated use {@link module:jira/api/events}
 */
define('jira/util/events', /** @alias module:jira/util/events */['jira/api/events'], function (jiraEvents) {
  'use strict';

  return jiraEvents;
});