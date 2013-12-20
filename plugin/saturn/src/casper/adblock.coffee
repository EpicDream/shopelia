#   CasperAdBlock
# Author : Vincent Renaudineau
# Created at : 2013-09-05

define ['vendor/adblock/matcher'], (Matcher) ->
  console.log(typeof Matcher)

  AdBlock = {}

  return AdBlock


# lib/prefs.js
# lib/utils.js
# lib/elemHideHitRegistration.js
# adblockplus/lib/downloader.js
# adblockplus/lib/filterNotifier.js
# adblockplus/lib/filterClasses.js
# adblockplus/lib/subscriptionClasses.js
# adblockplus/lib/filterStorage.js
# adblockplus/lib/elemHide.js
# adblockplus/lib/matcher.js
# adblockplus/lib/filterListener.js
# adblockplus/lib/synchronizer.js
# adblockplus/lib/notification.js
# lib/stats.js


# let {FilterStorage} = require("filterStorage");
# let {Filter} = require("filterClasses");
# let {Subscription, SpecialSubscription, RegularSubscription, DownloadableSubscription, ExternalSubscription} = require("subscriptionClasses");

# const externalPrefix = "~external~";

# /**
#  * Class implementing public Adblock Plus API
#  * @class
#  */
# var AdblockPlus =
# {
#   /**
#    * Returns current subscription count
#    * @type Integer
#    */
#   get subscriptionCount()
#   {
#     return FilterStorage.subscriptions.length;
#   },

#   /**
#    * Gets a subscription by its URL
#    */
#   getSubscription: function(/**String*/ id) /**IAdblockPlusSubscription*/
#   {
#     if (id in FilterStorage.knownSubscriptions)
#       return createSubscriptionWrapper(FilterStorage.knownSubscriptions[id]);

#     return null;
#   },

#   /**
#    * Gets a subscription by its position in the list
#    */
#   getSubscriptionAt: function(/**Integer*/ index) /**IAdblockPlusSubscription*/
#   {
#     if (index < 0 || index >= FilterStorage.subscriptions.length)
#       return null;

#     return createSubscriptionWrapper(FilterStorage.subscriptions[index]);
#   },

#   /**
#    * Updates an external subscription and creates it if necessary
#    */
#   updateExternalSubscription: function(/**String*/ id, /**String*/ title, /**Array of Filter*/ filters) /**String*/
#   {
#     if (id.substr(0, externalPrefix.length) != externalPrefix)
#       id = externalPrefix + id;
#     let subscription = Subscription.knownSubscriptions[id];
#     if (typeof subscription == "undefined")
#       subscription = new ExternalSubscription(id, title);

#     subscription.lastDownload = parseInt(new Date().getTime() / 1000);

#     let newFilters = [];
#     for each (let filter in filters)
#     {
#       filter = Filter.fromText(Filter.normalize(filter));
#       if (filter)
#         newFilters.push(filter);
#     }

#     if (id in FilterStorage.knownSubscriptions)
#       FilterStorage.updateSubscriptionFilters(subscription, newFilters);
#     else
#     {
#       subscription.filters = newFilters;
#       FilterStorage.addSubscription(subscription);
#     }

#     return id;
#   },

#   /**
#    * Removes an external subscription by its identifier
#    */
#   removeExternalSubscription: function(/**String*/ id) /**Boolean*/
#   {
#     if (id.substr(0, externalPrefix.length) != externalPrefix)
#       id = externalPrefix + id;
#     if (!(id in FilterStorage.knownSubscriptions))
#       return false;

#     FilterStorage.removeSubscription(FilterStorage.knownSubscriptions[id]);
#     return true;
#   },

#   /**
#    * Adds user-defined filters to the list
#    */
#   addPatterns: function(/**Array of String*/ filters)
#   {
#     for each (let filter in filters)
#     {
#       filter = Filter.fromText(Filter.normalize(filter));
#       if (filter)
#       {
#         filter.disabled = false;
#         FilterStorage.addFilter(filter);
#       }
#     }
#   },

#   /**
#    * Removes user-defined filters from the list
#    */
#   removePatterns: function(/**Array of String*/ filters)
#   {
#     for each (let filter in filters)
#     {
#       filter = Filter.fromText(Filter.normalize(filter));
#       if (filter)
#         FilterStorage.removeFilter(filter);
#     }
#   },

#   /**
#    * Returns installed Adblock Plus version
#    */
#   getInstalledVersion: function() /**String*/
#   {
#     return require("info").addonVersion;
#   },

#   /**
#    * Returns source code revision this Adblock Plus build was created from (if available)
#    */
#   getInstalledBuild: function() /**String*/
#   {
#     return "";
#   },
# };

# /**
#  * Wraps a subscription into IAdblockPlusSubscription structure.
#  */
# function createSubscriptionWrapper(/**Subscription*/ subscription) /**IAdblockPlusSubscription*/
# {
#   if (!subscription)
#     return null;

#   return {
#     url: subscription.url,
#     special: subscription instanceof SpecialSubscription,
#     title: subscription.title,
#     autoDownload: true,
#     disabled: subscription.disabled,
#     external: subscription instanceof ExternalSubscription,
#     lastDownload: subscription instanceof RegularSubscription ? subscription.lastDownload : 0,
#     downloadStatus: subscription instanceof DownloadableSubscription ? subscription.downloadStatus : "synchronize_ok",
#     lastModified: subscription instanceof DownloadableSubscription ? subscription.lastModified : null,
#     expires: subscription instanceof DownloadableSubscription ? subscription.expires : 0,
#     getPatterns: function()
#     {
#       let result = subscription.filters.map(function(filter)
#       {
#         return filter.text;
#       });
#       return result;
#     }
#   };
# }
