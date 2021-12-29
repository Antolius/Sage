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

public class Sage.Widgets.GuessRow : Gtk.Grid {

    public int current_color { get; set; }
    public Game game { get; construct; }
    public int row { get; construct; }

    public GuessRow (Game game, int row) {
        Object (
            game: game,
            row: row
        );
    }

    construct {
        column_spacing = 8;

        update_row_class ();
        game.notify["current-turn"].connect (update_row_class);
        get_style_context ().add_class ("circular");

        for (int i = 0; i < game.code_length; i++) {
            var btn = new GuessToggle (game, row, i);
            bind_property (
                "current_color",
                btn,
                "current_color",
                BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE
            );

            attach (btn, i, 0);
        }

        var separator = new Gtk.Separator (Gtk.Orientation.VERTICAL);
        attach (separator, game.code_length, 0);

        var hints_grid = new HintsGrid (game, row);
        attach (hints_grid, game.code_length + 1, 0);

        var validate_btn = new ValidateRowButton (game, row);
        attach (validate_btn, game.code_length + 2, 0);
    }

    private void update_row_class () {
        var ctx = get_style_context ();
        if (game.current_turn == row) {
            ctx.add_class (Granite.STYLE_CLASS_CARD);
        } else {
            ctx.remove_class (Granite.STYLE_CLASS_CARD);
        }
    }
}

