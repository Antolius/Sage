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

public class Sage.Widgets.HeaderBar : Hdy.HeaderBar {

    public Game game { get; construct; }

    public HeaderBar (Game game) {
        Object (game: game);
    }

    construct {
        has_subtitle = false;
        show_close_button = true;
        decoration_layout = "close";
        custom_title = create_mode_switcher ();
        pack_start (create_new_game_button ());
        pack_end (create_help_button ());
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
            game.reconfigure (4, 6);
        } else {
            game.reconfigure (5, 8);
        }
    }

    private Gtk.Button create_new_game_button () {
        var btn = new Gtk.Button.from_icon_name (
            "view-refresh-symbolic",
            Gtk.IconSize.SMALL_TOOLBAR
        ) {
            tooltip_text = _("Start a new game")
        };

        btn.clicked.connect (game.reset);
        return btn;
    }

    private Gtk.ToggleButton create_help_button () {
        var btn = new Gtk.ToggleButton () {
            tooltip_text = _("Show help"),
            always_show_image = true,
            image = new Gtk.Image () {
                gicon = new ThemedIcon ("help-contents-symbolic"),
                pixel_size = 16
            }
        };

        var id = btn.clicked.connect (game.toggle_help_tour);
        game.notify["help-tour-step"].connect (() => {
            if (game.help_tour_step == Game.NO_HELP) {
                SignalHandler.block (btn, id);
                btn.active = false;
                SignalHandler.unblock (btn, id);
            }
        });

        return btn;
    }
}

public delegate void Sage.Widgets.OnNewGame ();
