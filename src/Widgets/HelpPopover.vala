/*
* Copyright 2022 Josip Antoliš. (https://josipantolis.from.hr)
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

public class Sage.Widgets.HelpPopover : Gtk.Popover {

    public string help_text { get; construct; }

    public HelpPopover (
        Gtk.Widget relative_to,
        int help_tour_stop
    ) {
        Object (
            relative_to: relative_to,
            help_text: get_help_text_for (help_tour_stop),
            position: Gtk.PositionType.TOP
        );
    }

    private static string get_help_text_for (int stop) {
        switch (stop) {
            case Game.GUESS_HELP:
                return _("Try to match the secret code by coloring pins. All " +
                "pins in the row need to be colored, and several pins can " +
                "share the same color. As the game progresses, you'll gain " +
                "more insight, but at first it's ok to pick a couple of " +
                "colors at random.");
            case Game.VALIDATE_HELP:
                return _("After coloring all pins in the row, you can compare" +
                " it with the secret code.");
            case Game.HINT_HELP:
                return _("You received at most one hint for each pin. Now you" +
                " need to figure out which hint corresponds to which pin. As " +
                "you play, you'll submit more rows for validation, so make " +
                "sure to consider all their hints. Remember: secret code " +
                "remains the same throughout the game!");
            default:
                return "";
        }
    }

    construct {
        modal = false;
        child = new Gtk.Label (help_text) {
            margin = 8,
            wrap = true,
            width_chars = 24,
            max_width_chars = 24,
            lines = 4,
        };
    }
}
