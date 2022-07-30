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

public class Sage.Widgets.GuessRow : Gtk.Grid {

    public int current_color { get; set; }
    public Game game { get; construct; }
    public int row { get; construct; }

    private Gtk.Popover? help_popover;

    public GuessRow (Game game, int row) {
        Object (
            game: game,
            row: row
        );
    }

    construct {
        column_spacing = 8;
        add_css_class (Granite.STYLE_CLASS_CIRCULAR);

        update_row_class ();
        game.notify["current-turn"].connect (update_row_class);
        game.notify["help-tour-step"].connect (update_help_popover);

        var flags = BindingFlags.BIDIRECTIONAL | BindingFlags.SYNC_CREATE;
        for (int i = 0; i < game.code_length; i++) {
            var btn = new GuessToggle (game, row, i);
            bind_property ("current_color", btn, "current_color", flags);
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
        if (game.current_turn == row) {
            add_css_class (Granite.STYLE_CLASS_CARD);
        } else {
            remove_css_class (Granite.STYLE_CLASS_CARD);
        }
    }

    private void update_help_popover () {
        var on_turn = game.current_turn == row;
        var guess_help = game.help_tour_step == Game.GUESS_HELP;
        if (on_turn && guess_help) {
            if (help_popover == null) {
                help_popover = new HelpPopover (Game.GUESS_HELP);
                help_popover.set_parent (this);
            }

            help_popover.popup ();
        } else if (help_popover != null) {
            help_popover.popdown ();
        }
    }
}
