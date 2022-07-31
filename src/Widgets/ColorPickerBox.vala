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

public class Sage.Widgets.ColorPickerBox : Gtk.Box {

    public Game game { get; construct; }
    public int selected { get; set; }

    public ColorPickerBox (Game game) {
        Object (
            game: game,
            orientation: Gtk.Orientation.HORIZONTAL,
            spacing: 0,
            halign: Gtk.Align.CENTER
        );
    }

    construct {
        add_css_class (Granite.STYLE_CLASS_LINKED);

        Gtk.ToggleButton btn_group = null;
        for (int i = 0; i < game.number_of_colors; i++) {
            var label = new Gtk.Label (
                game.color_blind_mode ? "%d".printf (i + 1) : ""
            ) {
                height_request = 33,
                width_request = 33
            };
            label.add_css_class (Colors.STYLE_CLASS[i]);

            var btn = new Gtk.ToggleButton () {
                active = btn_group == null,
                child = label
            };
            btn.add_css_class ("guess");

            if (btn_group == null) {
                btn_group = btn;
            } else {
                btn.set_group (btn_group);
            }

            var color_id = i;
            btn.toggled.connect (() => {
                if (btn.active) {
                    selected = color_id;
                }
            });

            game.notify["color-blind-mode"].connect (() => {
                if (game.color_blind_mode) {
                    label.label = "%d".printf (color_id + 1);
                } else {
                    label.label = "";
                }
            });

            append (btn);
        }
    }
}
