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

public class Sage.Widgets.GuessToggle : Gtk.ToggleButton {

    public int current_color { get; set; }
    public Game game { get; construct; }
    public int row { get; construct; }
    public int column { get; construct; }

    private int guess { get { return game.guesses[row][column]; } }

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
        add_css_class (Granite.STYLE_CLASS_CIRCULAR);
        add_css_class ("guess");
        update_button_activity ();

        toggled.connect (handle_toggle);
        realize.connect (update_button_sensitivity);
        game.notify["current-turn"].connect (update_button_sensitivity);
        game.notify["guesses"].connect (update_button_activity);
        game.notify["color-blind-mode"].connect (update_label);
    }

    private void update_button_sensitivity () {
        sensitive = row == game.current_turn;
        if (sensitive && column == 0) {
            grab_focus ();
        }
    }

    private void update_button_activity () {
        if (guess == Game.EMPTY_GUESS) {
            active = false;
            clear_color_class ();
            update_label ();
        } else {
            active = true;
            add_css_class (Colors.STYLE_CLASS[guess]);
            update_label ();
        }
    }

    private void clear_color_class () {
        foreach (string color_class in Colors.STYLE_CLASS) {
            remove_css_class (color_class);
        }
    }

    private void handle_toggle () {
        if (active && guess == Game.EMPTY_GUESS) {
            game.submit_a_guess (column, current_color);
        } else if (!active && guess != Game.EMPTY_GUESS) {
            game.submit_a_guess (column, Game.EMPTY_GUESS);
        }
    }

    private void update_label () {
        if (game.color_blind_mode && guess != Game.EMPTY_GUESS) {
            label = "%d".printf (guess + 1);
        } else {
            label = null;
        }
    }

}
