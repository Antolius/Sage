/*
* Copyright 2021 Josip Antoliš. (https://josipantolis.from.hr)
*
* This program is free software; you can redistribute it and/or
* modify it under the terms of the GNU General Public
* License as published by the Free Software Foundation; either
* version 3 of the License, or (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* General Public License for more details.
*
* You should have received a copy of the GNU General Public
* License along with this program; if not, write to the
* Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
* Boston, MA 02110-1301 USA
*
*/

public class Sage.Store : Object {

    public Settings settings { get; construct; }
    private ThreadPool<KeyVal>? worker;

    public Store (Settings settings) {
        Object (settings: settings);
        try {
            worker = new ThreadPool<KeyVal>.with_owned_data (store, 1, true);
        } catch (ThreadError err) {
            warning ("Failed to create thread pool, will fall back to sync " +
            "calls to settings. Error: %s", err.message);
            worker = null;
        }
    }

    public int get_int (string key) {
        return settings.get_int (key);
    }

    public bool get_boolean (string key) {
        return settings.get_boolean (key);
    }

    public Variant get_value (string key) {
        return settings.get_value (key);
    }

    public void set_int (string key, int val) {
        enqueue (new KeyVal.from_integer (key, val));
    }

    public void set_boolean (string key, bool val) {
        enqueue (new KeyVal.from_boolean (key, val));
    }

    public void set_value (string key, Variant val) {
        enqueue (new KeyVal.from_vaiant (key, val));
    }

    private void enqueue (KeyVal kv) {
        if (worker != null) {
            try {
                worker.add (kv);
                return;
            } catch (ThreadError err) {
                warning ("Failed to enqueue change to %s, will fall back to " +
                "sync call to settings. Error: %s", kv.key, err.message);
            }
        }

        store (kv);
    }

    private void store (owned KeyVal kv) {
        if (kv.variant != null) {
            settings.set_value (kv.key, kv.variant);
        }

        if (kv.integer != null) {
            settings.set_int (kv.key, kv.integer);
        }

        if (kv.boolean != null) {
            settings.set_boolean (kv.key, kv.boolean);
        }
    }

    public void shutdown_gracefully (int timeout_milliseconds = 10000) {
        ThreadPool.free ((owned) worker, false, true);
    }
}

private class Sage.KeyVal : Object {
    public string key;
    public Variant? variant;
    public int? integer;
    public bool? boolean;

    public KeyVal.from_vaiant (string key, Variant variant) {
        this.key = key;
        this.variant = variant;
        this.integer = null;
        this.boolean = null;
    }

    public KeyVal.from_integer (string key, int integer) {
        this.key = key;
        this.variant = null;
        this.integer = integer;
        this.boolean = null;
    }

    public KeyVal.from_boolean (string key, bool boolean) {
        this.key = key;
        this.variant = null;
        this.integer = null;
        this.boolean = boolean;
    }
}
