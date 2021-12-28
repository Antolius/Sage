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

public class Sage.Board : Gtk.Grid {

    public int current_color { get; set; default = 0; }

    public Game game { get; construct; }

    public Board (Game game) {
        Object (
            margin: 12,
            row_spacing: 12,
            game: game
        );
    }

    construct {
        for (int i = 0; i < game.max_guesses; i++) {
            var row = create_guess_row (game.max_guesses - i - 1);
            attach (row, 0, i);
        }

        var color_picker = create_color_picker ();
        attach (color_picker, 0, game.max_guesses);
    }

    private Gtk.Widget create_guess_row (int row_num) {
        var row = new Gtk.Grid () {
            column_spacing = 8,
        };

        update_row_class (row, row_num);
        game.notify["current-turn"].connect (() => {
            update_row_class (row, row_num);
        });

        row.get_style_context ().add_class ("circular");

        for (int i = 0; i < game.code_length; i++) {
            var btn = create_guess_toggle (row_num, i);
            row.attach (btn, i, 0);
        }

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        row.attach (separator, game.code_length, 0);
        var hints_grid = create_hints_grid (row_num);
        row.attach (hints_grid, game.code_length + 1, 0);
        var validate_btn = create_validate_button (row_num);
        row.attach (validate_btn, game.code_length + 2, 0);
        return row;
    }

    private void update_row_class (Gtk.Grid row, int row_num) {
        var ctx = row.get_style_context ();
        if (game.current_turn == row_num) {
            ctx.add_class (Granite.STYLE_CLASS_CARD);
        } else {
            ctx.remove_class (Granite.STYLE_CLASS_CARD);
        }
    }

    private Gtk.ToggleButton create_guess_toggle (int row_num, int idx) {
        var btn = new Gtk.ToggleButton () {
            height_request = 32,
            width_request = 32,
            margin_start = 8,
            margin_top = 8,
            margin_bottom = 8,
            sensitive = row_num == game.current_turn,
        };

        game.notify["current-turn"].connect (() => {
            btn.sensitive = row_num == game.current_turn;
        });

        update_guess_button (row_num, idx, btn);
        game.notify["guesses"].connect (() => {
            update_guess_button (row_num, idx, btn);
        });

        btn.toggled.connect (() => {
            var game_state = game.guesses[row_num][idx];
            if (btn.active && game_state == Game.EMPTY_GUESS) {
                game.submit_a_guess (idx, current_color);
            } else if (!btn.active && game_state != Game.EMPTY_GUESS) {
                game.submit_a_guess (idx, Game.EMPTY_GUESS);
            }
        });

        btn.get_style_context ().add_class ("circular");
        return btn;
    }

    private void update_guess_button (
        int row_num,
        int idx,
        Gtk.ToggleButton btn
    ) {
        var guess = game.guesses[row_num][idx];
        if (guess == Game.EMPTY_GUESS) {
            btn.active = false;
            clear_color_class (btn);
        } else {
            btn.active = true;
            set_color_class (btn, guess);
        }
    }

    private void clear_color_class (Gtk.ToggleButton btn) {
        var ctx = btn.get_style_context ();
        foreach (string color_class in Colors.STYLE_CLASS) {
            ctx.remove_class (color_class);
        }
    }

    private void set_color_class (Gtk.ToggleButton btn, int color_idx) {
        var color_class = Colors.STYLE_CLASS[color_idx];
        btn.get_style_context ().add_class (color_class);
    }

    private Gtk.Grid create_hints_grid (int row_num) {
        var grid = new Gtk.Grid () {
            row_spacing = 0,
            column_spacing = 0,
            margin_top = 2,
            margin_bottom = 2,
        };

        var icons = new Gtk.Image[game.code_length];
        for (int i = 0; i < game.code_length; i++) {
            icons[i] = new Gtk.Image () {
                gicon = new ThemedIcon ("emblem-disabled"),
                pixel_size = 22,
                tooltip_text = _("")
            };

            grid.attach (icons[i], i / 2, i % 2);
        }

        update_hint_icons (row_num, icons);
        game.notify["hints"].connect (() => {
            update_hint_icons (row_num, icons);
        });

        return grid;
    }

    private void update_hint_icons (int row_num, Gtk.Image[] icons) {
        var hint = game.hints[row_num];
        for (int i = 0; i < hint.correct_colors_count; i++) {
            if (i < hint.correct_positions_count) {
                icons[i].gicon = new ThemedIcon ("emblem-enabled");
                icons[i].tooltip_text = _("Correct color on a correct position");
            } else {
                icons[i].gicon = new ThemedIcon ("emblem-mixed");
                icons[i].tooltip_text = _("Correct color on a wrong position");
            }

            icons[i].show_all ();
        }
    }

    private Gtk.Button create_validate_button (int row_num) {
        var btn = new Gtk.Button.from_icon_name (
            "emblem-readonly",
            Gtk.IconSize.LARGE_TOOLBAR
        ) {
            margin_end = 8,
            margin_top = 8,
            margin_bottom = 8,
            sensitive = false,
        };

        btn.clicked.connect (() => game.validate_current_row ());
        update_validate_button (row_num, btn);
        game.notify["can-validate"].connect (() => {
            update_validate_button (row_num, btn);
        });

        btn.get_style_context ().add_class ("circular");
        return btn;
    }

    private void update_validate_button (int row_num, Gtk.Button btn) {
        var is_on_turn = row_num == game.current_turn;
        btn.sensitive = is_on_turn && game.can_validate;
    }

    private Gtk.Widget create_color_picker () {
        var color_picker = new Granite.Widgets.ModeButton ();

        for (int i = 0; i < game.number_of_colors; i++) {
            var color = new Gdk.Pixbuf (Gdk.Colorspace.RGB, true, 8, 32, 32);
            color.fill (Colors.CODE[i]);
            color_picker.append_pixbuf (color);
        }

        bind_property (
            "current_color",
            color_picker,
            "selected",
            BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
        );

        return color_picker;
    }
}

