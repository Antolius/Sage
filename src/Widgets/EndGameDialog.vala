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

public class Sage.Widgets.EndGameDialog : Granite.MessageDialog {

    public EndGameDialog () {
        base.with_image_from_icon_name (
            _("Victory"),
            _("Congratulations, you've cracked the code."),
            "face-cool",
            Gtk.ButtonsType.NONE
        );
    }

    public EndGameDialog.defeat () {
        base.with_image_from_icon_name (
            _("Defeat"),
            _("You failed to cracked the code."),
            "face-angry",
            Gtk.ButtonsType.NONE
        );
    }

    construct {
        add_button (_("Quit"), Gtk.ResponseType.CANCEL);
        var replay = add_button (_("Play Again"), Gtk.ResponseType.ACCEPT);
        replay.get_style_context ().add_class (Gtk.STYLE_CLASS_SUGGESTED_ACTION);
        set_default_response (Gtk.ResponseType.ACCEPT);
    }

    public void display_code (int[] code) {
        var row = new Gtk.Grid () {
            column_spacing = 12,
            margin_top = 8,
            margin_bottom = 8,
            hexpand = false,
        };

        var row_ctx = row.get_style_context ();
        row_ctx.add_class (Granite.STYLE_CLASS_CARD);
        row_ctx.add_class ("circular");

        for (int i = 0; i < code.length; i++) {
            var btn = new Gtk.ToggleButton () {
                height_request = 32,
                width_request = 32,
                margin = 8,
                hexpand = false,
                sensitive = false,
            };

            var btn_ctx = btn.get_style_context ();
            btn_ctx.add_class ("circular");
            btn_ctx.add_class (Colors.STYLE_CLASS[code[i]]);
            row.attach (btn, i, 0);
        }

        row.show_all ();
        custom_bin.add (row);
    }
}

