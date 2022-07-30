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

public class Sage.Widgets.HeaderBar : Gtk.Box {

    public Game game { get; construct; }

    public HeaderBar (Game game) {
        Object (game: game);
    }

    construct {
        var bar = new Gtk.HeaderBar () {
            hexpand = true,
            show_title_buttons = true,
            decoration_layout = "close",
            title_widget = create_mode_switcher ()
        };

        bar.pack_start (create_new_game_button ());
        bar.pack_end (create_help_button ());

        append (bar);
    }

    private Gtk.Box create_mode_switcher () {
        var btns = new Gtk.Box (Gtk.Orientation.HORIZONTAL, 0);
        btns.add_css_class (Granite.STYLE_CLASS_LINKED);

        var classic = new Gtk.ToggleButton.with_label (_("Classic"));
        classic.active = determine_mode_from_game () == 0;
        btns.append (classic);
        var advanced = new Gtk.ToggleButton.with_label (_("Advanced"));
        advanced.active = determine_mode_from_game () == 1;
        advanced.set_group (classic);
        btns.append (advanced);

        classic.toggled.connect (() => {
            switch_mode_to (classic.active ? 0 : 1);
        });

        return btns;
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
            "view-refresh-symbolic"
        ) {
            tooltip_text = _("Start a new game")
        };

        btn.clicked.connect (game.reset);
        return btn;
    }

    private Gtk.ToggleButton create_help_button () {
        var btn = new Gtk.ToggleButton () {
            tooltip_text = _("Show help"),
            icon_name = "help-contents-symbolic"
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
