/*
 * This file is part of Adblock Plus <http://adblockplus.org/>,
 * Copyright (C) 2006-2013 Eyeo GmbH
 *
 * Adblock Plus is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 3 as
 * published by the Free Software Foundation.
 *
 * Adblock Plus is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Adblock Plus.  If not, see <http://www.gnu.org/licenses/>.
 */

/**
 * @fileOverview This component manages listeners and calls them to distributes
 * messages about filter changes.
 */

define(function() {
  /**
   * List of registered listeners
   * @type Array of function(action, item, newValue, oldValue)
   */
  var listeners = [];

  /**
   * This class allows registering and triggering listeners for filter events.
   * @class
   */
  var FilterNotifier = exports.FilterNotifier =
  {
    /**
     * Adds a listener
     */
    addListener: function(/**function(action, item, newValue, oldValue)*/ listener)
    {
      if (listeners.indexOf(listener) >= 0)
        return;

      listeners.push(listener);
    },

    /**
     * Removes a listener that was previosly added via addListener
     */
    removeListener: function(/**function(action, item, newValue, oldValue)*/ listener)
    {
      var index = listeners.indexOf(listener);
      if (index >= 0)
        listeners.splice(index, 1);
    },

  };

  return FilterNotifier;
});
