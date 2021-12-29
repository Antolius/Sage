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

public class Sage.Widgets.HintsGrid : Gtk.Grid {

    public Game game { get; construct; }
    public int row { get; construct; }

    public HintsGrid (Game game, int row) {
        Object (
            game: game,
            row: row
        );
    }

    construct {
        row_spacing = 0;
        column_spacing = 0;
        margin_top = 2;
        margin_bottom = 2;

        var icons = new Gtk.Image[game.code_length];
        for (int i = 0; i < game.code_length; i++) {
            icons[i] = new Gtk.Image () {
                gicon = new ThemedIcon ("emblem-disabled"),
                pixel_size = 22,
                tooltip_text = _("")
            };

            attach (icons[i], i / 2, i % 2);
        }

        update_hint_icons (icons);
        game.notify["hints"].connect (() => {
            update_hint_icons (icons);
        });
    }

    private void update_hint_icons (Gtk.Image[] icons) {
        var hint = game.hints[row];
        for (int i = 0; i < game.code_length; i++) {
            if (i < hint.correct_positions_count) {
                mark_as_correct_position (icons[i]);
            } else if (i < hint.correct_colors_count){
                mark_as_correct_color (icons[i]);
            } else {
                mark_as_a_miss (icons[i]);
            }

            icons[i].show_all ();
        }
    }

    private void mark_as_correct_position (Gtk.Image icon) {
        icon.gicon = new ThemedIcon ("emblem-enabled");
        icon.tooltip_text = _("Correct color on a correct position");
    }

    private void mark_as_correct_color (Gtk.Image icon) {
        icon.gicon = new ThemedIcon ("emblem-mixed");
        icon.tooltip_text = _("Correct color on a wrong position");
    }

    private void mark_as_a_miss (Gtk.Image icon) {
        icon.gicon = new ThemedIcon ("emblem-disabled");
        icon.tooltip_text = null;
    }
}

