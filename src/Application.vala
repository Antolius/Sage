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

public class Sage.Application : Gtk.Application {

    public Settings state;

    public Application () {
        Object (
            application_id: "hr.from.josipantolis.sage",
            flags: ApplicationFlags.FLAGS_NONE
        );

        state = new Settings ("hr.from.josipantolis.sage");
    }

    protected override void activate () {
        unowned var existing_windows = get_windows ();
        if (existing_windows.length () > 0) {
            var window = existing_windows.first ().data as MainWindow;
            window.present ();
        } else {
            var window = new MainWindow (this);
            window.show ();
        }
    }

    public override void startup () {
        base.startup ();
        Hdy.init ();
        foce_elementary_style ();
        link_dark_mode_settings ();
    }

    public static int main (string[] args) {
        return new Application ().run (args);
    }

    private void foce_elementary_style () {
        var settings = Gtk.Settings.get_default ();
        if (!settings.gtk_theme_name.has_prefix ("io.elementary.stylesheet")) {
            settings.gtk_theme_name = "io.elementary.stylesheet.blueberry";
        }

        if (settings.gtk_icon_theme_name != "elementary") {
            settings.gtk_icon_theme_name = "elementary";
        }
    }

    private void link_dark_mode_settings () {
        var granite_settings = Granite.Settings.get_default ();
        var gtk_settings = Gtk.Settings.get_default ();

        var dark_mode = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
        gtk_settings.gtk_application_prefer_dark_theme = dark_mode;

        granite_settings.notify["prefers-color-scheme"].connect (() => {
            var dark_mode = granite_settings.prefers_color_scheme == Granite.Settings.ColorScheme.DARK;
            gtk_settings.gtk_application_prefer_dark_theme = dark_mode;
        });
    }
}
