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

public class Sage.Widgets.BoardGrid : Gtk.Grid {

    public int current_color { get; set; default = 0; }
    public Game game { get; construct; }

    public BoardGrid (Game game) {
        Object (
            margin: 12,
            row_spacing: 12,
            game: game
        );
    }

    construct {
        create_rows ();
        game.game_reset_started.connect (reset);
        game.game_reset_finished.connect (create_rows);
    }

    private void reset () {
        get_children ().foreach (remove);
        current_color = 0;
    }

    private void create_rows () {
        var bind_flags = BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE;
        for (int i = 0; i < game.max_guesses; i++) {
            var row = new GuessRow (game, game.max_guesses - i - 1);
            bind_property ("current_color", row, "current_color", bind_flags);
            attach (row, 0, i);
        }

        var color_picker = new ColorPickerButton (game);
        bind_property ("current_color", color_picker, "selected", bind_flags);
        attach (color_picker, 0, game.max_guesses);
        show_all ();
    }
}
