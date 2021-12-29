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

public class Sage.Widgets.HeaderBar : Hdy.HeaderBar {

    public Game game { get; construct; }

    private OnNewGame on_new_game;

    public HeaderBar (Game game, OnNewGame on_new_game) {
        Object (game: game);
        this.on_new_game = () => on_new_game ();
    }

    construct {
        has_subtitle = false;
        show_close_button = true;
        decoration_layout = "close";
        custom_title = create_mode_switcher ();
        var new_game = create_new_game_button ();
        pack_start (new_game);
    }

    private Granite.Widgets.ModeButton create_mode_switcher () {
        var btn = new Granite.Widgets.ModeButton ();
        btn.append_text (_("Classic"));
        btn.append_text (_("Advanced"));
        btn.selected = determine_mode_from_game ();
        btn.mode_changed.connect (() => {
            switch_mode_to (btn.selected);
        });

        return btn;
    }

    private int determine_mode_from_game () {
        if (game.code_length == 4 && game.number_of_colors == 6) {
            return 0;
        }

        return 1;
    }

    private void switch_mode_to (int mode) {
        if (mode == 0) {
            game.code_length = 4;
            game.number_of_colors = 6;
        } else {
            game.code_length = 5;
            game.number_of_colors = 8;
        }

        on_new_game ();
    }

    private Gtk.Button create_new_game_button () {
        var btn = new Gtk.Button.from_icon_name  (
            "view-refresh-symbolic",
            Gtk.IconSize.SMALL_TOOLBAR
        ) {
            tooltip_text = _("Start a new game")
        };

        btn.clicked.connect (() => on_new_game ());

        return btn;
    }
}

public delegate void Sage.Widgets.OnNewGame ();

