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

    private const int EMPTY_GUESS = -1;

    public int current_color { get; set; default = 0; }
    public bool can_submit_a_guess { get; set; default = false; }

    public Game game { get; construct; }
    public Gee.List<int> current_guess { get; set; }

    public Board (Game game) {
        Object (
            margin: 12,
            row_spacing: 12,
            game: game,
            current_guess: empty_guesses (game.code_length)
        );
    }

    private static Gee.List<int> empty_guesses (int size) {
        var guesses = new Gee.ArrayList<int> ();
        for (int i = 0; i < size; i++) {
            guesses.add (EMPTY_GUESS);
        }

        return guesses;
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

        game.notify.connect (() => {
            var ctx = row.get_style_context ();
            if (game.current_turn == row_num) {
                ctx.add_class (Granite.STYLE_CLASS_CARD);
            } else {
                ctx.remove_class (Granite.STYLE_CLASS_CARD);
            }
        });

        if (game.current_turn == row_num) {
            row.get_style_context ().add_class (Granite.STYLE_CLASS_CARD);
        }

        row.get_style_context ().add_class ("circular");

        for (int i = 0; i < game.code_length; i++) {
            var btn = create_guess_toggle (row_num, i);
            row.attach (btn, i, 0);
        }

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        row.attach (separator, game.code_length, 0);
        Gtk.Image[] hint_icons;
        var hints_grid = create_hints_grid (out hint_icons);
        row.attach (hints_grid, game.code_length + 1, 0);
        var submit = create_submit_button (row_num, hint_icons);
        row.attach (submit, game.code_length + 2, 0);
        return row;
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

        game.notify.connect (() => {
            btn.sensitive = row_num == game.current_turn;
        });

        btn.toggled.connect (() => make_a_guess (btn, idx));
        btn.get_style_context ().add_class ("circular");
        return btn;
    }

    private Gtk.Grid create_hints_grid (out Gtk.Image[] icons) {
        var grid = new Gtk.Grid () {
            row_spacing = 0,
            column_spacing = 0,
            margin_top = 2,
            margin_bottom = 2,
        };

        icons = new Gtk.Image[game.code_length];
        for (int i = 0; i < game.code_length; i++) {
            icons[i] = new Gtk.Image () {
                gicon = new ThemedIcon ("emblem-disabled"),
                pixel_size = 22,
                tooltip_text = _("")
            };

            grid.attach (icons[i], i / 2, i % 2);
        }

        return grid;
    }

    private Gtk.Button create_submit_button (int row_num, owned Gtk.Image[] hints) {
        var submit = new Gtk.Button.from_icon_name (
            "emblem-readonly",
            Gtk.IconSize.LARGE_TOOLBAR
        ) {
            margin_end = 8,
            margin_top = 8,
            margin_bottom = 8,
            sensitive = false,
        };

        submit.clicked.connect (() => {
            var hint = game.submit_a_guess (current_guess.to_array ());
            can_submit_a_guess = false;
            current_guess = empty_guesses (game.code_length);
            for (int i = 0; i < hint.correct_colors_count; i++) {
                if (i < hint.correct_positions_count) {
                    hints[i].gicon = new ThemedIcon ("emblem-enabled");
                    hints[i].tooltip_text = _("Correct color on a correct position");
                } else {
                    hints[i].gicon = new ThemedIcon ("emblem-mixed");
                    hints[i].tooltip_text = _("Correct color on a wrong position");
                }

                hints[i].show_all ();
            }
        });

        bind_property (
            "can_submit_a_guess",
            submit,
            "sensitive",
            BindingFlags.DEFAULT,
            (b, f, ref to_val) => {
                to_val = can_submit_a_guess && game.current_turn == row_num;
                return true;
            }
        );

        submit.get_style_context ().add_class ("circular");
        return submit;
    }

    private void make_a_guess (Gtk.ToggleButton guessed_btn, int idx) {
        if (!guessed_btn.active) {
            current_guess[idx] = EMPTY_GUESS;
            foreach (string color_class in Colors.STYLE_CLASS) {
                guessed_btn.get_style_context ().remove_class (color_class);
            }
        } else {
            current_guess[idx] = current_color;
            var color_class = Colors.STYLE_CLASS[current_color];
            guessed_btn.get_style_context ().add_class (color_class);
        }

        var guess_is_full = true;
        foreach (var guess in current_guess) {
            guess_is_full = guess_is_full && guess != EMPTY_GUESS;
        }

        can_submit_a_guess = guess_is_full;
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

