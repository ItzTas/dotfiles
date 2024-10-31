define('jira/customfields/customfieldsPaginationDetailsView', ['jira/marionette-4.1'], function (Marionette) {
  'use strict';

  return Marionette.View.extend({
    initialize: function initialize() {
      this.listenTo(this.collection, 'sync', this.render);
    },
    template: function template(_ref) {
      var start = _ref.start,
        end = _ref.end,
        total = _ref.total;
      return JIRA.Templates.Admin.Customfields.paginationDetails({
        start: start,
        end: end,
        total: total
      });
    },
    templateContext: function templateContext() {
      var _this$collection$stat = this.collection.state,
        totalRecords = _this$collection$stat.totalRecords,
        currentPage = _this$collection$stat.currentPage,
        pageSize = _this$collection$stat.pageSize;
      return {
        start: this.getStart(currentPage, pageSize, totalRecords),
        end: this.getEnd(currentPage, pageSize, totalRecords),
        total: totalRecords
      };
    },
    /**
     * Helper to compute pagination details - a record number we are starting with.
     * @param currentPage {Number}
     * @param pageSize {Number}
     * @param total {Number}
     * @returns {number}
     */
    getStart: function getStart(currentPage, pageSize, total) {
      if (total === 0) {
        return 0;
      }
      return (currentPage - 1) * pageSize + 1;
    },
    /**
     * Helper to compute pagination details - a record number we are ending with.
     * @param currentPage {Number}
     * @param pageSize {Number}
     * @param total {Number}
     * @returns {number}
     */
    getEnd: function getEnd(currentPage, pageSize, total) {
      if (currentPage * pageSize > total) {
        return total;
      }
      return currentPage * pageSize;
    }
  });
});