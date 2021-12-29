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

public class Sage.Widgets.GuessToggle : Gtk.ToggleButton {

    public int current_color { get; set; }
    public Game game { get; construct; }
    public int row { get; construct; }
    public int column { get; construct; }

    public GuessToggle (Game game, int row, int column) {
        Object (
            game: game,
            row: row,
            column: column
        );
    }

    construct {
        height_request = 32;
        width_request = 32;
        margin_start = 8;
        margin_top = 8;
        margin_bottom = 8;
        sensitive = row == game.current_turn;
        get_style_context ().add_class ("circular");

        game.notify["current-turn"].connect (() => {
            sensitive = row == game.current_turn;
            if (sensitive && column == 0) {
                grab_focus ();
            }
        });

        update_guess_button ();
        game.notify["guesses"].connect (() => {
            update_guess_button ();
        });

        toggled.connect (() => {
            var game_state = game.guesses[row][column];
            if (active && game_state == Game.EMPTY_GUESS) {
                game.submit_a_guess (column, current_color);
            } else if (!active && game_state != Game.EMPTY_GUESS) {
                game.submit_a_guess (column, Game.EMPTY_GUESS);
            }
        });

        if (row == 0 && column == 0) {
            realize.connect (grab_focus);
        }
    }

    private void update_guess_button () {
        var guess = game.guesses[row][column];
        if (guess == Game.EMPTY_GUESS) {
            active = false;
            clear_color_class ();
        } else {
            active = true;
            set_color_class (guess);
        }
    }

    private void clear_color_class () {
        var ctx = get_style_context ();
        foreach (string color_class in Colors.STYLE_CLASS) {
            ctx.remove_class (color_class);
        }
    }

    private void set_color_class (int color_idx) {
        var color_class = Colors.STYLE_CLASS[color_idx];
        get_style_context ().add_class (color_class);
    }

}

