define("jira/viewissue/watchers-voters/views/abstract-watchers-view",["require"],(function(e){"use strict";var t=e("aui/message"),i=e("jira/backbone-1.3.3"),r=e("underscore"),n=e("jquery"),s=e("jira/jquery/deferred"),a=e("jira/util/formatter");return i.View.extend({$empty:void 0,renderNoWatchers:function(){if(0===this.$(".recipients li").length){this.$empty=t.info({closeable:!1,body:a.I18n.getText("watcher.manage.nowatchers")});this.$("fieldset").append(this.$empty)}else this.$empty&&this.$empty.remove()},render:function(){var e=s();this.collection.fetch().done(r.bind((function(){this._render();this.renderNoWatchers();e.resolve(this.$el);setTimeout(r.bind((function(){this.focus()}),this),0)}),this));return e.promise()},watch:function(){n("#watching-toggle").text(a.I18n.getText("issue.operations.simple.stopwatching"))},unwatch:function(){n("#watching-toggle").text(a.I18n.getText("issue.operations.simple.startwatching"))},focus:n.noop,_incrementWatcherCount:function(){var e=n("#watcher-data"),t=parseInt(e.text(),10);e.text(t+1);this.renderNoWatchers()},_decrementWatcherCount:function(){var e=n("#watcher-data"),t=parseInt(e.text(),10);e.text(t-1);this.renderNoWatchers()}})}));